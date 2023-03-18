package kit;

// A `Product` is a Result that only accepts a `kit.Error`
// as its error type?
typedef Product<T> = Result<T, Error>;
