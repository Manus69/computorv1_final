module my_exception;

static immutable enum ErrorType
{
    GENERAL, DEGREE, ARRAY, NUMERIC, SYNTAX, SIZE,
    BALANCE, SYMBOL, MISSING_INPUT, TOKEN, SOLUTION,
    ARGUMENTS,
}

static immutable string[ErrorType.max + 1] messages =
[ErrorType.GENERAL : "Something is wrong",
ErrorType.ARGUMENTS : "Wrong number of command line arguments",
ErrorType.DEGREE : "The degree of the polynomial  is too large",
ErrorType.ARRAY : "Array allocation failure",
ErrorType.SOLUTION : "The program only solves polynomial equations of degree 3 or less",
ErrorType.NUMERIC : "Failed at arithmetic",
ErrorType.SYNTAX : "Syntax error",
ErrorType.SIZE : "The thing is too big",
ErrorType.BALANCE : "The equation must have the form p(x) = q(x)",
ErrorType.SYMBOL : "The variable symbols don't match",
ErrorType.MISSING_INPUT : "There is no input",
ErrorType.TOKEN : "Malformed token ",];

string get_message(ErrorType error_type, string additional_message)
{
    return messages[error_type] ~ additional_message;
}

void my_throw(ErrorType type, string extra_message = "")
{
    throw new MyException(get_message(type, extra_message));
}

class MyException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}