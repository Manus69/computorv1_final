module sqrt;

import support;

static const double PRECISION = 1.0 / (1 << 4);
static const double HIGH_PRECISION = 1.0 / (1 << 15);

//x^2 + a = 0
double my_sqrt_newtons(double a, double x0)
{
    double f_prime;
    double f;

    f = x0 * x0 - a;

    while (abs(f) > HIGH_PRECISION)
    {
        f_prime = 2 * x0;
        x0 = x0 - f / f_prime;
        f = x0 * x0 - a;
    }

    return x0;
}

double my_sqrt_newtons(double a)
{
    if (a < 0)
        return double.nan;

    return my_sqrt_newtons(a, 1);
}

double my_sqrt(double x)
{
    if (x < 0 || abs(x) > int.max)
        return double.nan;
        
    return my_sqrt_newtons(x);
}