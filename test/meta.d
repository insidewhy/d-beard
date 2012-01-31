module beard.test.find;

import beard.meta.find;
import beard.meta.contains_match;
import beard.io;

template isFloat(T) {
   enum isFloat = is(T == float);
}

int main() {
    println(typeid(find!(isFloat, bool, bool, bool, float)));
    println(typeid(find!(isFloat, bool, bool, int, int)));
    println(containsMatch!(isFloat, bool, bool, bool, float));
    println(containsMatch!(isFloat, bool, bool, int, int));
    return 0;
}
