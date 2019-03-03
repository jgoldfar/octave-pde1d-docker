function example1()

%*****************************************************************************80
%
%% EXAMPLE1 demonstrates the use of PDEPE on a scalar PDE.
%
%  Discussion:
%
%    Solve the heat equation.
%
%    PDE:
%      ut = uxx
%    BC:
%      u(t,0) = 0 = u(t,1)
%    IC:
%      u(0,x) = 2x*(1-x)/(1+x^2)
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    29 August 2013
%
%  Author:
%
%    Original formulation by P Howard, 2005.
%    This version by John Burkardt
%    Updated to add assertion and change problem by Jonathan Goldfarb, 2019
%
  timestamp ( );
  fprintf ( 1, '\n' );
  fprintf ( 1, 'EXAMPLE1:\n' );
  fprintf ( 1, '  The heat equation.\n' );
  fprintf ( 1, '  ut = uxx\n' );
  fprintf ( 1, '  u(t,0) = 0 = u(t,1)\n' );
  fprintf ( 1, '  u(0,x) = 2x*(1-x)/(1+x^2)\n' );
%
%  M defines the coordinate system:
%  0: cartesian
%  1: cylindrical
%  2: spherical
%
  m = 0;
%
%  Define the spatial mesh.
%
  nx = 21;
  xmesh = linspace ( 0.0, 1.0, nx );
%
%  Define the time mesh.
%
  nt = 11;
  tspan = linspace ( 0.0, 2.0, nt );
%
%  Call PDEPE() for the solution.
%
  sol = pdepe ( m, @pdefun, @icfun, @bcfun, xmesh, tspan );
%
%  Even though our solution is "really" a 2D array, PDEPE stores it
%  in a 3D array SOL(:,:,:).  The surf() command needs a 2D array to plot,
%  so let's copy U out of SOL.
%
  u = sol(:,:,1);

%
%  Terminate.
%

  % Added by Jonathan Goldfarb, 3/2/2019: We expect the solution to this problem to
  % decrease towards the steady state (which is identically zero) from its non-negative
  % initial data.
  for i = 2:2:(nx-1)
    assert (all(diff(u(:, i)) <= 0))
  end

  % Boundary conditions hold for x=0 (i=1)
  assert (all(abs(u(:, 1)) < 1e-10))
  % and for x=1 (i=end)
  assert (all(abs(u(:, end)) < 1e-10))

  assert (all(size(u) == [nt, nx]))
  % End addition by Jonathan Goldfarb, 3/2/2019
  
  fprintf ( 1, '\n' );
  fprintf ( 1, 'EXAMPLE1:\n' );
  fprintf ( 1, '  Normal end of execution.\n' );
  fprintf ( 1, '\n' );
  timestamp ( );

  return
end
function [ c, f, s ] = pdefun ( x, t, u, dudx )

%*****************************************************************************80
%
%% PDEFUN defines the components of the PDE.
%
%  Discussion:
%
%    The PDE has the form:
%
%      c * du/dt = x^(-m) d/dx ( x^m f ) + s
%
%    where m is 0, 1 or 2,
%    c, f and s are functions of x, t, u, and dudx,
%    and most typically, f = dudx.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    29 August 2013
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, real X, the spatial location.
%
%    Input, real T, the current time.
%
%    Input, real U(:,1), the estimated solution at T and X.
%
%    Input, real DUDX(:,1), the estimated spatial derivative of U at T and X.
%
%    Output, real C(:,1), the coefficients of du/dt.
%
%    Output, real F(:,1), the flux terms.
%
%    Output, real S(:,1), the source terms.
%
  c = 1.0;
  f = dudx;
  s = 0.0;

  return
end
function u0 = icfun ( x )

%*****************************************************************************80
%
%% ICFUN defines the initial conditions.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    29 August 2013
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, real X, the spatial location.
%
%    Output, real U0(:,1), the value of the solution at the initial time,
%    and location X.
%
  u0 = 2.0 * x .* (1-x) ./ ( 1.0 + x.^2 );

  return
end
function [ pl, ql, pr, qr ] = bcfun ( xl, ul, xr, ur, t )

%*****************************************************************************80
%
%% BCFUN defines the boundary conditions.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    29 August 2013
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, real XL, the spatial coordinate of the left boundary.
%
%    Input, real UL(:,1), the solution estimate at the left boundary.
%
%    Input, real XR, the spatial coordinate of the right boundary.
%
%    Input, real UR(:,1), the solution estimate at the right boundary.
%
%    Output, real PL(:,1), the Dirichlet portion of the left boundary condition.
%
%    Output, real QL(:,1), the coefficient of the flux portion of the left
%    boundary condition.
%
%    Output, real PR(:,1), the Dirichlet portion of the right boundary condition.
%
%    Output, real QR(:,1), the coefficient of the flux portion of the right
%    boundary condition.
%
  pl = ul;
  ql = 0.0;
  pr = ur;
  qr = 0.0;

  return
end
function timestamp ( )

%*****************************************************************************80
%
%% TIMESTAMP prints the current YMDHMS date as a timestamp.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    14 February 2003
%
%  Author:
%
%    John Burkardt
%
  t = now;
  c = datevec ( t );
  s = datestr ( c, 0 );
  fprintf ( 1, '%s\n', s );

  return
end
