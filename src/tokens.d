module tokens;

import std.ascii;
import std.conv;

import my_exception;
import recognizers;

static immutable enum TokenType
{
    DEFAULT, PLUS, MINUS, STAR, CARET, EQUALS, TERM, NUMERIC, BRICK, MALFORMED,
}

static immutable enum int MAX_DEGREE = (1 << 5);
static immutable enum char NUL = '\0';
static immutable enum char DEFAULT_SYMBOL = 'X';

class Term
{
    public double _coefficient;
    public int _degree;
    public char _symbol;

    this()
    {
        _coefficient = double.nan;
        _degree = -1;
        _symbol = NUL;
    }

    this(double coefficient)
    {
        this._coefficient = coefficient;
        this._symbol = '\0';
        this._degree = 0;
    }

    this(char symbol)
    {
        this._coefficient = 1;
        this._degree = 1;
        this._symbol = symbol;
    }

    this(double coefficient, char symbol, int degree)
    {
        this._coefficient = coefficient;
        this._symbol = symbol;
        this._degree = degree;
    }

    this(Token[] tokens)
    {
        if (tokens.length == 0)
            this();
        else if (tokens.length == 1)
            this(tokens[0]);
        else if (tokens.length == 2)
            this(tokens[0], tokens[1]);
        else if (tokens.length == 3)
            this(tokens[0], tokens[1], tokens[2]);
        else if (tokens.length == 4)
            this(tokens[0], tokens[1], tokens[2], tokens[3]);
        else
            this();        
    }

    private this(Token token)
    {
        if (token._type == TokenType.NUMERIC)
            this(to!double(token._string));
        else if (token._type == TokenType.TERM)
            this(token._term._coefficient, token._term._symbol, token._term._degree);
        else
            this();
    }

    private this(Token t0, Token t1)
    {
        int sign;

        sign = t0._type == TokenType.MINUS ? -1 : 1;

        if (t0._type == TokenType.MINUS || t0._type == TokenType.PLUS)
        {
            this(t1);
            this._coefficient *= sign;
        }
        else
        {
            this();
        }
    }

    private this(Token t0, Token t1, Token t2)
    {
        if (t0._type == TokenType.NUMERIC && t1._type == TokenType.STAR && t2._type == TokenType.TERM)
            this(to!double(t0._string), t2._term._symbol, t2._term._degree);
        else
            this();
    }

    private this(Token t0, Token t1, Token t2, Token t3)
    {
        double value;

        if (t0._type != TokenType.PLUS && t0._type != TokenType.MINUS)
            this();
        else if (t1._type != TokenType.NUMERIC && t2._type != TokenType.STAR && t3._type != TokenType.TERM)
            this();
        else
        {
            value = to!double(t1._string);
            this(t0._type == TokenType.MINUS ? -1 * value : value, t3._term._symbol, t3._term._degree);
        }
    }

    bool is_valid()
    {
        return (!(this._coefficient is double.nan) &&
        (this._degree >= 0) && (this._degree <= MAX_DEGREE) &&
        ((isAlpha(this._symbol)) || this._symbol == NUL));
    }
}

class Token
{
    private string _string;
    private int _current_index;
    private TokenType _type;
    private Term _term;

    this(string str)
    {
        if (str.length >= int.max || str.length == 0)
            my_throw(ErrorType.GENERAL);

        _string = str;
        _current_index = 0;
        _type = TokenType.DEFAULT;
        _term = null;

        this._type = _classify_and_parse();

        if (this._type == TokenType.TERM)
        {
            if (!this._term.is_valid())
                this._type = TokenType.BRICK;
            
            if (this._term._degree > MAX_DEGREE)
                my_throw(ErrorType.DEGREE, MAX_DEGREE.stringof);
        }

        if (this._type == TokenType.MALFORMED)
            my_throw(ErrorType.TOKEN, this._string);

        if (this._type == TokenType.BRICK || this._type == TokenType.DEFAULT)
            my_throw(ErrorType.SYNTAX, " at token " ~ this._string);
    }

    TokenType get_type()
    {
        return this._type;
    }

    Token set_type(TokenType type)
    {
        this._type = type;

        return this;
    }

    private TokenType _classify_single_char()
    {
        if (is_char(this._string, '-'))
            return TokenType.MINUS;
        else if (is_char(this._string, '+'))
            return TokenType.PLUS;
        else if (is_char(this._string, '*'))
            return TokenType.STAR;
        else if (is_char(this._string, '='))
            return TokenType.EQUALS;
        else
            return _parse_term_singleton();
    }

    private TokenType _parse_term_singleton()
    {
        if (isAlpha(this._string[0]))
        {
            this._term = new Term(this._string[0]);
            this._type = TokenType.TERM;

            return TokenType.TERM;
        }
        else if (isDigit(this._string[0]))
        {
            return TokenType.NUMERIC;
        }

        return TokenType.BRICK;
    }

    //c | cx | cx^d | x | -x | x^d | -x^d
    private TokenType _verify_term(int c_length, int pt_length, int caret_length, int d_length)
    {
        TokenType type;
        double coefficient;

        type = TokenType.TERM;
        if (c_length)
        {
            coefficient = to!double(this._string[0 .. c_length]);
            if (!pt_length && !caret_length && !d_length)
                this._term = new Term(coefficient);
            else if (pt_length == 1 && !caret_length && !d_length)
                this._term = new Term(coefficient, this._string[c_length], 1);
            else if (pt_length == 1 && caret_length && d_length)
                this._term = 
                new Term(coefficient, this._string[c_length], to!int(this._string[this._current_index .. $]));
            else
                type = TokenType.MALFORMED;
        }
        else
        {
            if (pt_length == 1 && !caret_length && !d_length)
                this._term = new Term(1, this._string[0], 1);
            else if (pt_length == 2 && !caret_length && !d_length)
                this._term = new Term(-1, this._string[1], 1);
            else if (pt_length == 1 && caret_length == 1 && d_length)
                this._term = new Term(1, this._string[0], to!int(this._string[this._current_index .. $]));
            else if (pt_length == 2 && caret_length && d_length)
                this._term = new Term(-1, this._string[1], to!int(this._string[this._current_index .. $]));
            else
                type = TokenType.MALFORMED;
        }
        return type;
    }

    private TokenType _parse_term()
    {
        int c_length;
        int pt_length;
        int caret_length;
        int d_length;

        c_length = is_double(this._string);
        this._current_index += c_length;

        pt_length = is_partial_term(this._string[this._current_index .. $]);
        this._current_index += pt_length;

        caret_length = is_caret(this._string[this._current_index .. $]);
        this._current_index += caret_length;

        d_length = is_integer_strict(this._string[this._current_index .. $]);

        if (!caret_length && !d_length)
            pt_length = is_partial_term_strict(this._string[c_length .. $]);

        if (!pt_length && !caret_length && !d_length && (c_length != this._string.length))
            my_throw(ErrorType.TOKEN, this._string);

        return _verify_term(c_length, pt_length, caret_length, d_length);
    }

    private TokenType _classify_and_parse()
    {
        if (this._string.length == 0)
            return TokenType.BRICK;
        
        if (this._string.length == 1)
            return this._classify_single_char();
        
        if (is_double_strict(this._string))
            return TokenType.NUMERIC;

        return _parse_term();
    }
}