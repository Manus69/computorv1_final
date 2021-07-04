module polynomial;

import my_exception;
import complex;
import solvers;
import numeric_solvers;


class Polynomial
{
    private double[] _coefficients;
    private int _degree;
    private char _symbol;

    private static const uint DEFAULT_SIZE = (1 << 1);
    private static const uint MAX_SIZE = (1 << 10);
    private static const uint MAX_DEGREE = 10;
    public static const char DEFAULT_SYMBOL = 'X';

    private this(uint size)
    {
        if (size == 0 || size > MAX_SIZE)
            my_throw(ErrorType.GENERAL);
        
        this._coefficients = new double[size];
        this._coefficients[] = 0;
        this._degree = 0;
        this._symbol = '\0';
    }

    this()
    {
        this(DEFAULT_SIZE);
    }

    this(double[] values)
    {
        if (values is null || values == [] || values.length > int.max)
            my_throw(ErrorType.GENERAL);

        this();

        this._coefficients = new double[values.length];
        this._coefficients[] = values;
        this._degree = this._check_degree();
    }

    this(double coefficient, char symbol, uint degree)
    {
        if (degree > MAX_SIZE)
            my_throw(ErrorType.DEGREE);

        this(degree + 1);
        this._symbol = symbol;
        this.set_coefficient(coefficient, degree);
    }

    this(Polynomial p)
    {
        this();
        this._set_values(p._coefficients, p._degree, p._symbol);
    }

    private void _set_values(double[] coefficients, uint degree, char symbol)
    {
        this._coefficients = coefficients;
        this._degree = degree;
        this._symbol = symbol;
    }

    double get_coefficient(uint n)
    {
        return (this._degree < n) ? 0 : this._coefficients[n];
    }

    uint get_degree()
    {
        return this._degree;
    }

    char get_symbol()
    {
        return this._symbol;
    }

    bool is_zero()
    {
        int n;

        n = 0;
        while (n <= this._degree)
        {
            if (this._coefficients[n] != 0)
                return false;
            n ++;
        }

        return true;
    }

    private Polynomial _set_coefficient(double value, uint degree)
    {
        this._coefficients[degree] = value;

        return this;
    }

    Polynomial set_coefficient(double value, uint degree)
    {
        if (degree >= this._coefficients.length)
            this._coefficients = _extend(degree - cast(uint) this._coefficients.length + 1);
        
        this._set_coefficient(value, degree);

        if (degree >= this._degree && value != 0)
            this._degree = degree;

        return this;
    }

    Polynomial add(Polynomial p)
    {
        double result;
        int n;
        
        if (this._symbol == '\0')
            this._symbol = p._symbol;

        if (this._symbol != p._symbol && p._symbol != '\0')
            throw new MyException(get_message(ErrorType.SYMBOL, ""));

        n = p._degree;
        while (n >= 0)
        {
            result = this.get_coefficient(n) + p.get_coefficient(n);
            this.set_coefficient(result, n);
            n --;
        }

        this._degree = this._check_degree();

        return this;
    }

    Polynomial scale(double value)
    {
        this._coefficients[] *= value;
        this._degree = this._check_degree();

        return this;
    }

    Polynomial multiply(Polynomial p)
    {
        int k;
        int n;
        int max_degree;
        double coefficient;
        Polynomial result;

        if (this._symbol != p._symbol && this._symbol != '\0' && p._symbol != '\0')
            return this;

        n = 0;
        max_degree = this._degree + p._degree;
        result = new Polynomial(max_degree);

        while (n <= max_degree)
        {
            k = 0;
            coefficient = 0;
            while (k <= n)
            {
                coefficient += this.get_coefficient(k) * p.get_coefficient(n - k);
                k ++;
            }
            result.set_coefficient(coefficient, n);
            n ++;
        }

        result._degree = result._check_degree();
        _set_values(result._coefficients, result._degree, result._symbol);

        return this;
    }

    Polynomial normalize()
    {
        double high_coefficient;
        double coefficient;
        int n;

        n = this.get_degree();
        high_coefficient = this.get_coefficient(n);

        if (high_coefficient == 0)
            return this;

        while (n >= 0)
        {
            coefficient = this.get_coefficient(n);
            this.set_coefficient(coefficient / high_coefficient, n);
            n --;
        }

        return this;
    }

    Polynomial differentiate()
    {
        Polynomial derivative;
        double coefficient;
        int n;

        derivative = new Polynomial(this._degree);
        n = 1;
        while (n <= this._degree)
        {
            coefficient = this.get_coefficient(n) * n;
            derivative.set_coefficient(coefficient, n - 1);
            n ++;
        }

        derivative._check_degree();

        return derivative;
    }

    private bool _compare_coefficients(Polynomial p)
    {
        int n;

        if (this._degree != p._degree)
            return false;

        n = 0;
        while (n <= p.get_degree())
        {
            if (this.get_coefficient(n) != p.get_coefficient(n))
                return false;
            n ++;
        }

        return true;
    }

    Polynomial factor(Polynomial p)
    {
        Polynomial quotient;
        Polynomial partial_divisor;
        Polynomial result;
        double weight;
        
        if (p._degree > this._degree)
            return new Polynomial();
        
        if (p._degree == this._degree)
        {
            if (this._compare_coefficients(p))
                return new Polynomial(1, this._symbol, 0);
            return new Polynomial();
        }

        quotient = new Polynomial();
        result = new Polynomial(this._coefficients);

        while (result._degree >= p._degree)
        {
            weight = result.get_coefficient(result._degree) / p.get_coefficient(p._degree);
            partial_divisor = new Polynomial(weight, result._symbol, result._degree - p._degree);

            quotient.add(partial_divisor);
            partial_divisor.multiply(p);
            result.add(partial_divisor.scale(-1));
        }

        return quotient;
    }

    double evaluate(double x)
    {
        double result;
        double coefficient;
        int n;

        n = this.get_degree();

        if (n > MAX_DEGREE)
            my_throw(ErrorType.DEGREE);
            
        result = 0;

        while (n >= 0)
        {
            coefficient = this.get_coefficient(n);
            result = result * x + coefficient;
            n --;
        }

        return result;
    }

    Complex[] get_roots()
    {
        if (this._degree == 0)
            return solve_constant_eqn(this._coefficients[0 .. this._degree + 1]);
        else if (this._degree == 1)
            return solve_linear_eqn(this._coefficients[0 .. this._degree + 1]);
        else if (this._degree == 2)
            return solve_quadratic_eqn(this._coefficients[0 .. this._degree + 1]);
        else if (this._degree == 3)
            return _find_cubic_roots();

        my_throw(ErrorType.SOLUTION);
        assert(0);
    }

    private Complex[] _find_cubic_roots()
    {
        Complex r0;
        Complex[] roots;
        Polynomial quotient;
        Polynomial divisor;

        r0 = new Complex(find_root_newtons(this), 0);

        if (r0._re is double.nan)
            my_throw(ErrorType.NUMERIC, " trying to find a root numerically");

        divisor = new Polynomial([-r0._re, 1]);
        quotient = this.factor(divisor);

        roots = solve_quadratic_eqn(quotient._coefficients);
        roots ~= r0;

        return roots;
    }

    private uint _check_degree()
    {
        int n;

        if (this._coefficients.length == 0)
            throw new MyException(messages[ErrorType.GENERAL]);

        n = cast(int) this._coefficients.length - 1;

        while (n >= 0)
        {
            if (this._coefficients[n] != 0)
                break ;
            n --;
        }

        return n < 0 ? 0 : n;
    }

    private double[] _extend(uint extension_size)
    {
        double[] extension;

        if (extension_size == 0)
            return this._coefficients;

        if (this._coefficients.length + extension_size > this.MAX_SIZE)
            throw new MyException(messages[ErrorType.ARRAY]);

        extension = new double[extension_size];
        extension[] = 0;

        return this._coefficients ~ extension;
    }
}