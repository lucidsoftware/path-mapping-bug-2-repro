def _impl(ctx):
    output_file = ctx.actions.declare_file("foo.jar")
    outputs = [output_file]

    inputs = ctx.attr.dep[JavaInfo].transitive_runtime_jars

    args = ctx.actions.args()
    args.add("--output", output_file)
    args.add_all("--sources", inputs)

    ctx.actions.run(
        arguments = [args],
        mnemonic = "SingleJar",
        executable = ctx.executable._singlejar,
        execution_requirements = {
            "supports-path-mapping": "1",
        },
        inputs = inputs,
        outputs = outputs,
        progress_message = "Running singlejar on %{label}",
    )

    return [
        DefaultInfo(files = depset(outputs)),
    ]

example_rule = rule(
    implementation = _impl,
    doc = "Runs singlejar on a single dep, which is not useful.",
    attrs = {
        "_singlejar": attr.label(
            allow_single_file = True,
            cfg = "exec",
            default = "@rules_java//toolchains:singlejar",
            executable = True,
        ),
        "dep": attr.label(
            mandatory = True,
            providers = [JavaInfo],
        )
    },
)
