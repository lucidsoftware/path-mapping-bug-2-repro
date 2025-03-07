This is a minimal repro case for a Bazel bug where enabling pathmapping for the workspace and disabling sandboxing on a target via the `"no-sandbox"` tag causes the action to fail in unintuitive ways for some rules.

*Problem*\
This repo has a simple rule implemented in `example/example_rule.bzl` that wraps singlejar. That action supports pathmapping and sets the `"supports-path-mapping": "1"` execution requirement.

The repo sets up a custom Java toolchain, so path mapping will work with the Java rules.

When pathmapping + sandboxing are enabled, things work.

When pathmapping is enabled and the `no-sandbox` tag is set on `//example:example`, things break as follows:
`singlejar_local: src/tools/singlejar/output_jar.cc:322: bazel-out/cfg/bin/example/foo.jar: No such file or directory`

It seems that all paths passed to the singlejar command are not properly mapped. This is the command line that results in the error above. Note the `bazel-out/cfg/bin` in the paths.
```external/rules_java++toolchains+remote_java_tools_linux/java_tools/src/tools/singlejar/singlejar_local --output bazel-out/cfg/bin/example/foo.jar --sources bazel-out/cfg/bin/example/libexample_foo.jar```

*Oddity*\
The `no-sandbox` tag works fine on the `//example:example_java_library` depended upon by `//example:example`, so this doesn't seem to be a problem with `java_library`.

*Dependencies required*\
[bazelisk](https://github.com/bazelbuild/bazelisk)

*To reproduce the problem*\
Run `bazel build example`

*To mitigate the problem*\
Comment out or remove the `no-sandbox` tag on `//example:example` in `example/BUILD.bazel`