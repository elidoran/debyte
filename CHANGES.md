## 0.2.1 - Released 2017/05/20

1. remove unused script from package.json
2. add more string testing for prefixed/not, top-level, in object
3. revise test descriptions to pattern 'decode blah via blah2()'
4. provide string length to `unstring.learn()`
5. revise error'ing test descriptions to say which function is called
6. fix `value()` by adding missing get/new string specifiers

## 0.2.0 - Released 2017/05/20

1. update `@endeo/input` dep which changes its construction from an options object to `(buffer, index, options)`; changed code accordingly.
2. replace `this.specials.get(id)` with `this.specs[id]` because `@endeo/specials` doesn't store instances it only generates them. Then `endeo` stores them in an array (for now). So, it receives that array to "get" from.
3. tweaked some tests to the `[method1, method2].forEach` style of multi-method testing the same thing


## 0.1.0 - Released 2017/05/16

1. initial working version with 100% coverage
