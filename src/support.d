module support;

auto abs(T)(T value)
{
    return value < 0 ? -value : value;
}