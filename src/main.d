module main;

import std.stdio;
import std.ascii;
import std.array;

import polynomial;
import my_exception;
import parser;
import print;
import complex;

int display_usage()
{
    writeln("Usage: ./computor \"[string]\"");

    return 1;
}

int begin(string str)
{
    Polynomial p;
    Parser parser;
    Complex[] roots;

    try
    {
        parser = new Parser(str);
        p = parser.parse();
        roots = p.get_roots();

        write("Reduced form: ");
        print_polynomial(p, true);
        print_info(p);
        print_roots(roots);
        writeln();
    }
    catch (MyException e)
    {
        writeln("My exception: ", e.msg);
    }
    catch (Exception e)
    {
        writeln("System exception: ", e.msg);
    }

    return 0;
}

int main(string[] args)
{
    string str;

    if (args.length == 1)
    {
        str = readln();

        if (str is null)
            return display_usage();
    }
    else if (args.length > 2)
        return display_usage();
    else
        str = args[1];

    return begin(str);
}
