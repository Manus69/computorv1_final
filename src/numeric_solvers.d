module numeric_solvers;

import polynomial;
import support;
import complex;
import my_exception;

static const double RANGE = 1 << 11;
static const double DELTA = 1.0 / (1 << 15);
static const double EPSILON = 1.0 / (1 << 8);

// p must have degree 3
static double _pick_the_right_root(Polynomial p, Polynomial derivative)
{
    Complex[] roots;
    Polynomial second_derivative;
    double root;

    roots = derivative.get_roots();
    if (roots.length == 0)
        return double.nan;
    
    if (roots.length == 1)
        return roots[0]._re;

    second_derivative = derivative.differentiate();

    if (roots[1]._im != 0)
        return double.nan;

    root = roots[1]._re;

    if (second_derivative.evaluate(root) > 0 && p.evaluate(root) <= 0)
        return root;
    if (second_derivative.evaluate(root) < 0 && p.evaluate(root) >= 0)
        return root;
    
    return roots[0]._re;
}

static double _get_epsilon(Polynomial p, double x)
{
    double f;
    double epsilon;

    f = p.evaluate(x);
    epsilon = EPSILON;

    if (abs(f) < DELTA)
        return x;

    if (p.get_coefficient(p.get_degree()) < 0)
    {
        if (f < 0)
            epsilon = -EPSILON;
    }
    else
    {
        if (f > 0)
            epsilon = -EPSILON;
    }

    return epsilon;
}

static void _check_variables(double f, double f_prime, double x)
{
    if (abs(f) > float.max || abs(f_prime) > float.max || x > float.max)
        my_throw(ErrorType.NUMERIC);
    
}

//use this with even degree polynomials at your own risk
double find_root_newtons(Polynomial p)
{
    double x;
    double f;
    double f_prime;
    double epsilon;
    Polynomial derivative;

    derivative = p.differentiate();
    x = _pick_the_right_root(p, derivative);
    epsilon = _get_epsilon(p, x);
    x += epsilon;

    if (x is double.nan)
        x = 0;

    if (abs(x) > RANGE)
        my_throw(ErrorType.NUMERIC);

    f = p.evaluate(x);

    while (abs(f) > DELTA)
    {
        while ((f_prime = derivative.evaluate(x)) == 0)
        {
            x += epsilon;
            f = p.evaluate(x);
        }

        _check_variables(f, f_prime, x);

        x = x - f / f_prime;
        f = p.evaluate(x);
    }

    return x;
}