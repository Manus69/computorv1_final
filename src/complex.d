module complex;

class Complex
{
    double _re;
    double _im;

    this(double re, double im)
    {
        this._re = re;
        this._im = im;
    }

    bool is_real()
    {
        return this._im == 0 ? true : false;
    }

    bool is_equal(Complex z)
    {
        return (this._re == z._re) && (this._im == z._im);
    }

}

int compare_re(Complex z0, Complex z1)
{
    return z0._re > z1._re ? -1 : (z0._re != z1._re);
}

int compare_re_reverse(Complex z0, Complex z1)
{
    return -compare_re(z0, z1);
}
