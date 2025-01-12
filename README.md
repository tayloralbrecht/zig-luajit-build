# luajit-build

A Zig package that provides build integration for [LuaJIT][LUAJIT]. LuaJIT is a fork from the [Lua][LUA] project --
"Lua is a powerful, efficient, lightweight, embeddable scripting language."

[LUAJIT]: https://luajit.org/index.html
[LUA]: https://www.lua.org/about.html

## Looking for LuaJIT API Bindings?

This package only handles building and linking the LuaJIT library into a Zig application. It enables developers
to import the native C API into their Zig application. If you're looking for a LuaJIT Zig API, refer to these
other projects:

- [zig-luajit](https://github.com/sackosoft/zig-luajit) - Zig language bindings LuaJIT.
- [ziglua](https://github.com/natecraddock/ziglua) - Zig language bindings for LuaJIT, Lua 5.X, and Luau.

## Zig Version

The `main` branch targets Zig's `master` (nightly) deployment (currently `0.14.0-dev.XXXX`).

## Installation

It is recommended that you install using `zig fetch`:

```bash
zig fetch --save=luajit_build git+https://github.com/sackosoft/zig-luajit-build
```

You can also manually add the latest stable luajit-build to your `build.zig.zon`:

```zig
.dependencies = .{
    .luajit_build = .{
        .url = "git+https://github.com/sackosoft/zig-luajit-build.git#e98d8b13015a7777f46ba6cf8a76abbe141bf6ad",
        .hash = "12206f63cb55f24ef35d696641f5bdb4b176d7eb0dc39923580ac4f0831e3f6a1793",
    },
}
```

## Usage

In your `build.zig`, you'll need to (1) declare the `luajit-build` dependency, (2) get a reference to the `luajit-build`
module (which contains the LuaJIT C API), and (3) enable your code to import the `luajit-build` module.

```zig
// (1) Declare the dependency.
const luajit_build_dep = b.dependency("luajit_build", .{ 
    .target = target, 
    .optimize = optimize,
    .link_as = .static  // Or .dynamic to link as a shared library
});

// (2) Reference the native LuaJIT module.
const luajit_build = luajit_build_dep.module("luajit-build");

// Set up your library or executable
const lib = // ...
const exe = // ...

// (3) Add the LuaJIT module to your root module
lib.root_module.addImport("c", luajit_build);
// Or
exe.root_module.addImport("c", luajit_build);
```

In your Zig code, access the LuaJIT native bindings using the name of the import you added.

```zig
const c = @import("c");  // Access LuaJIT functions via 'c'
```

You can use a different import name if preferred:

```zig
lib.root_module.addImport("luajit", luajit_build);
const luajit = @import("luajit");
```

## Configuration

This package supports one configuration option, shown in the example above.

- `link_as`: Controls how LuaJIT is linked
  - `.static`: Build and link LuaJIT as a static library (default).
  - `.dynamic`: Build and link LuaJIT as a shared library.

