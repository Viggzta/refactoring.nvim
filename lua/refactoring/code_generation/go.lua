local code_utils = require("refactoring.code_generation.utils")

local string_pattern = "%s"

local function go_func_args_default_types(args)
    local new_args = {}
    for _, arg in ipairs(args) do
        table.insert(
            new_args,
            string.format("%s %s", arg, code_utils.default_func_param_type())
        )
    end
    return new_args
end

local function go_func_args_with_types(args, args_types)
    local args_with_types = {}
    for _, arg in ipairs(args) do
        table.insert(
            args_with_types,
            string.format("%s %s", arg, args_types[arg])
        )
    end
    return table.concat(args_with_types, ", ")
end

local function go_func_args(opts)
    if opts.args_types ~= nil then
        return go_func_args_with_types(opts.args, opts.args_types)
    else
        return table.concat(go_func_args_default_types(opts.args), ", ")
    end
end

local function go_function(opts)
    return string.format(
        [[
func %s(%s) {
%s
}
]],
        opts.name,
        go_func_args(opts),
        code_utils.stringify_code(opts.body)
    )
end

local function go_function_return(opts)
    if opts["return_type"] == nil then
        opts["return_type"] = code_utils.default_func_return_type()
    end

    return string.format(
        [[
func %s(%s) %s {
%s
}
]],
        opts.name,
        go_func_args(opts),
        opts.return_type,
        code_utils.stringify_code(opts.body)
    )
end

local function go_class_function(opts)
    return string.format(
        [[
func %s %s(%s) {
%s
}
]],
        opts.className,
        opts.name,
        go_func_args(opts),
        code_utils.stringify_code(opts.body)
    )
end

local function go_class_function_return(opts)
    return string.format(
        [[
func %s %s(%s) INPUT_RETURN_TYPE {
%s
}
]],
        opts.className,
        opts.name,
        go_func_args(opts),
        code_utils.stringify_code(opts.body)
    )
end

local function go_call_class_func(opts)
    return string.format(
        "%s.%s(%s)",
        opts.class_type,
        opts.name,
        table.concat(opts.args, ", ")
    )
end

local function constant(opts)
    return string.format(
        "%s := %s\n",
        code_utils.returnify(opts.name, string_pattern),
        opts.value
    )
end

local go = {
    comment = function(statement)
        return string.format("// %s", statement)
    end,
    print_var = function(prefix, var)
        return string.format(
            'fmt.Println(fmt.Sprintf("%s %%v", %s))',
            prefix,
            var
        )
    end,
    print = function(statement)
        return string.format('fmt.Println("%s")', statement)
    end,
    constant = function(opts)
        return constant(opts)
    end,
    ["return"] = function(code)
        return string.format("return %s", code_utils.stringify_code(code))
    end,
    ["function"] = function(opts)
        return go_function(opts)
    end,
    function_return = function(opts)
        return go_function_return(opts)
    end,
    class_function = function(opts)
        return go_class_function(opts)
    end,
    class_function_return = function(opts)
        return go_class_function_return(opts)
    end,
    pack = function(names)
        return code_utils.returnify(names, string_pattern)
    end,
    call_function = function(opts)
        return string.format("%s(%s)", opts.name, table.concat(opts.args, ", "))
    end,
    call_class_function = function(opts)
        return go_call_class_func(opts)
    end,
    terminate = function(code)
        return code .. "\n"
    end,
}
return go
