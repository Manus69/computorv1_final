module print;

import std.stdio;

import polynomial;
import complex;
import support;

void print_complex(Complex z)
{
    write("(", z._re, " , ", z._im, ")");
}

void print_complex_pretty(Complex z)
{
    write(z._re == 0 ? 0 : z._re);

    if (z._im != 0)
    {
        if (z._im > 0)
            write(" + ", z._im, "i");
        else
            write(" - ", -z._im, "i");
    }
}

static void _print_second_degree_roots(Complex[] roots)
{
    if (roots[0].is_equal(roots[1]))
    {
        write("The discriminant is zero;\nThe root is: ");
        write("[");
        print_complex_pretty(roots[0]);
        write("]");

        return ;
    }
    else if (roots[0].is_real())
    {
        write("The discriminant is positive;");
    }
    else
    {
        write("The discriminant is negative;");
    }

    write("\nThe roots are: [");
    print_complex_pretty(roots[0]);
    write(", ");
    print_complex_pretty(roots[1]);
    write("]");
}

void print_roots(Complex[] roots)
{
    string separator;

    if (roots is null || roots.length == 0)
        writeln("No roots");
    else if (roots.length == 1 && roots[0]._re is double.nan)
        writeln("Any number is a solution");
    else if (roots.length == 2)
        _print_second_degree_roots(roots);
    else
    {
        separator = "";
        write("The roots are: [");
        foreach (Complex root; roots)
        {
            write(separator);
            print_complex_pretty(root);
            separator = ", ";
        }
        write("]");

    }
}

void print_info(Polynomial p)
{
    writeln("Degree: ", p.get_degree());
}

//this is fucked up
int print_term(double value, char symbol, uint degree, int term_count)
{
    if (value < 0)
        write(" - ");
    if (term_count)
        write(" + ");
    write(abs(value), " * ", symbol, "^", degree);

    return 1;   
}

int pretty_print_term(double value, char symbol, uint degree, int term_count)
{
    if (value == 0)
        return 0;
    
    if (value < 0)
    {
        if (!term_count)
            write("-");
        else
            write(" - ");
    }

    if (term_count && value > 0)
        write(" + ");

    if (!degree)
        write(abs(value));
    
    if (degree)
    {
        if (abs(value) != 1)
            write(abs(value));
        write(symbol);
    }
    if (degree > 1)
        write("^", degree);
    
    return 1;
}

void print_polynomial(Polynomial p, bool pretty = false)
{
    int n;
    char symbol;
    double coefficient;
    int term_count;
    int function(double, char, uint, int) print;

    if (p.is_zero())
    {
        writeln("0 = 0");

        return ;
    }

    term_count = 0;
    n = 0;
    symbol = p.get_symbol() == '\0' ? p.DEFAULT_SYMBOL : p.get_symbol();
    print = pretty ? &pretty_print_term : &print_term;


    while (n <= p.get_degree())
    {
        coefficient = p.get_coefficient(n);
        term_count += print(coefficient, symbol, n, term_count);
        n ++;
    }

    write(" = 0\n");
}