module solvers;

import my_sqrt;
import my_exception;
import complex;
import support;

static void check_coefficients(double[] coefficients, uint number)
{
    if (coefficients.length != number)
        my_throw(ErrorType.GENERAL);
}

//a0 = 0
Complex[] solve_constant_eqn(double[] coefficients)
{
    Complex[] roots;

    check_coefficients(coefficients, 1);
    
    if (coefficients[0] == 0)
        roots ~= new Complex(double.nan, double.nan);
    
    return roots;
}

//a0 + a1x = 0
Complex[] solve_linear_eqn(double[] coefficients)
{
    Complex[] roots;
    Complex root;

    check_coefficients(coefficients, 2);

    if (coefficients[1] == 0)
        return solve_constant_eqn(coefficients[0 .. $ - 1]);

    root = new Complex(-(coefficients[0] / coefficients[1]), 0);
    roots ~= root;

    return roots;
}

//a0 + a1x + a2x^2 = 0
Complex[] solve_quadratic_eqn(double[] coefficients)
{
    Complex[] roots;
    Complex root;
    double discriminant;

    check_coefficients(coefficients, 3);

    if (coefficients[2] == 0)
        return solve_linear_eqn(coefficients[0 .. $ - 1]);

    discriminant = get_discriminant(coefficients);

    if (abs(discriminant) > int.max)
        my_throw(ErrorType.NUMERIC);

    if (discriminant == 0)
    {
        root = new Complex(-(coefficients[1] / (2 * coefficients[2])), 0);
        roots ~= root;
        roots ~= root;
    }
    else if (discriminant > 0)
    {
        root = new Complex((my_sqrt(discriminant) - coefficients[1]) / (2 * coefficients[2]), 0);
        roots ~= root;
        root = new Complex((-my_sqrt(discriminant) - coefficients[1]) / (2 * coefficients[2]), 0);
        roots ~= root;
    }
    else
    {
        root = new Complex(-coefficients[1] / (2 * coefficients[2]),
            my_sqrt(-1 * discriminant) / (2 * coefficients[2]));
        roots ~= root;
        
        root = new Complex(-coefficients[1] / (2 * coefficients[2]),
            -my_sqrt(-1 * discriminant) / (2 * coefficients[2]));
        roots ~= root;
    }

    return roots;
}

double get_discriminant(double[] coefficients)
{
    check_coefficients(coefficients, 3);

    return coefficients[1] * coefficients[1] - 4 * coefficients[0] * coefficients[2];
}