module recognizers;

import std.ascii;
import std.array;

import my_exception;

int is_char(string str, char c)
{
    if (str.length == 0)
        return 0;
    return (str[0] == c) ? 1 : 0;
}

int is_char_strict(string str, char c)
{
    return (is_char(str, c) == str.length);
}

int is_integer(string str)
{
    int n;

    if (str.length == 0)
        return 0;

    if (str[0] == '0' && str.length > 1)
        return 0;

    while (n < str.length)
    {
        if (!isDigit(str[n]))
            break ;
        n ++;
    }

    return n;
}

int is_int_like(string str)
{
    int n;

    if (str.length == 0)
        return 0;
    
    n = 0;
    while (n < str.length)
    {
        if (!isDigit(str[n]))
            break ;
        n ++;
    }

    return n;
}

int is_negative_int(string str)
{
    int n;

    if (str.length < 2)
        return 0;
    
    if (str[0] != '-')
        return 0;

    if (str[1] == '0')
        return 0;

    n = is_integer(str[1 .. $]);
    
    if (n == 0)
        return 0;

    return 1 + n;
}

int is_integer_strict(string str)
{
    if (str.length == 0)
        return 0;

    return (is_integer(str) == str.length) * cast(int) str.length;
}

int is_negative_int_strict(string str)
{
    if (str.length == 0)
        return 0;
    
    return (is_negative_int(str) == str.length) * cast(int) str.length;
}

int is_negative_zero_strict(string str)
{
    if (str.length != 2)
        return 0;
    
    if (str[0] == '-' && str[1] == '0')
        return 2;
    
    return 0;
}

int is_double(string str)
{
    string[] substrings;
    int int_part_size;
    int decimal_part_size;

    substrings = str.split(".");

    if (substrings.length == 1)
        return is_integer(substrings[0]) + is_negative_int(substrings[0]);

    if (substrings[0].length == 0)
        return 0;

    int_part_size = is_integer(substrings[0]) + 
    is_negative_int(substrings[0]) + is_negative_zero_strict(substrings[0]);

    if (int_part_size < substrings[0].length)
        return int_part_size;

    decimal_part_size = is_int_like(substrings[1]);

    if (decimal_part_size == 0)
        return int_part_size;

    return int_part_size + decimal_part_size + 1;
}

int is_double_strict(string str)
{
    if (str.length == 0)
        return 0;
    
    return (is_double(str) == str.length) * cast(int) str.length;
}

//x or -x
int is_partial_term(string str)
{
    if (str.length == 0)
        return 0;
 
    if (isAlpha(str[0]))
    {
        return 1;
    }
    else if (str[0] == '-' && str.length > 1 && isAlpha(str[1]))
        return 2;

    return 0;
}

int is_caret(string str)
{
    if (str.length == 0)
        return 0;

    if (str[0] == '^')
        return 1;
    
    return 0;
}

int is_partial_term_strict(string str)
{
    if (str.length == 0)
        return 0;
    
    return (is_partial_term(str) == str.length) * cast(int) str.length;
}