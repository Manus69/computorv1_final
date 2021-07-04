module parser;

import std.array;
import std.string;

import tokens;
import polynomial;
import my_exception;

class Parser
{
    private string _string_to_parse;
    private Polynomial _polynomial;

    this(string str)
    {
        if (str.length >= int.max)
            my_throw(ErrorType.SIZE);

        if (str.length == 0)
            my_throw(ErrorType.MISSING_INPUT);
        
        this._string_to_parse = str;
        this._polynomial = null;
    }

    private Token[] _get_tokens_after_numeric(string[] token_strings)
    {
        Token token;
        Token next_token;

        if (token_strings.length < 2)
            return [];

        token = new Token(token_strings[0]);
        next_token = new Token(token_strings[1]);

        if (token.get_type() == TokenType.STAR && next_token.get_type() == TokenType.TERM)
            return [] ~ token ~ next_token;

        return [];
    }

    //valid sequence: 
    //Term +- Term
    //Term: numeric | numeric partial | partial
    private Token[] _get_tokens(string[] token_strings)
    {
        Token[] tokens;
        Token current_token;

        while (token_strings.length)
        {
            current_token = new Token(token_strings[0]);
            tokens ~= current_token;

            if (current_token.get_type() == TokenType.NUMERIC)
                return tokens ~ _get_tokens_after_numeric(token_strings[1 .. $]);

            if (current_token.get_type() == TokenType.TERM)
                return tokens;

            token_strings = token_strings[1 .. $];
        }

        return tokens;
    }

    private Polynomial _parse_side(string str)
    {
        string[] token_strings;
        Token[] tokens;
        Term term;
        Term previous_term;
        Polynomial p;

        p = new Polynomial();
        token_strings = str.split(" ");
        previous_term = null;

        if (token_strings.length == 0)
            my_throw(ErrorType.GENERAL);

        while (token_strings.length != 0)
        {
            tokens = _get_tokens(token_strings);
            term = new Term(tokens);

            if (!term.is_valid())
                my_throw(ErrorType.SYNTAX, " after " ~ token_strings[0]);

            if (previous_term && tokens[0].get_type() != TokenType.MINUS && tokens[0].get_type() != TokenType.PLUS)
                my_throw(ErrorType.SYNTAX, " at " ~ token_strings[0]);

            p.add(new Polynomial(term._coefficient, term._symbol, term._degree));
            token_strings = token_strings[tokens.length .. $];
            previous_term = term;

        }

        return p;
    }

    Polynomial parse()
    {
        Polynomial lhs;
        Polynomial rhs;
        string[] substrings;

        this._string_to_parse = strip(this._string_to_parse);

        substrings = this._string_to_parse.split(" = ");
        if (substrings.length != 2 || substrings[0].length == 0 || substrings[1].length == 0)
            my_throw(ErrorType.BALANCE);
        
        lhs = _parse_side(substrings[0]);
        rhs = _parse_side(substrings[1]);
        this._polynomial = lhs.add(rhs.scale(-1));

        return this._polynomial;
    }
}