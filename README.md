# SDL 3.1.6 on Zig

This is a fork of [SDL](https://www.libsdl.org/), packaged for Zig (Initially by Andrew Kelley) and in-sync with the latest SDL 3 version in the main repository.
Unnecessary files have been deleted, and the build system has been replaced with `build.zig`

## Usage

We can easily fetch this library using `zig fetch`, for example:

```bash
zig fetch --save=sdl git+https://github.com/mdmrk/SDL#main
```

If another SDL version needed, please see available tags released.

In your `build.zig`:

```zig
const exe = b.addExecutable(.{
      .name = "my-project",
      .root_source_file = b.path("src/main.zig"),
      .target = target,
      .optimize = optimize,
  });

if (target.result.os.tag == .linux) {
    // It is suggested to link system SDL3 in Linux, as explained here:
    // https://ziggit.dev/t/build-allyourcodebase-sdl-on-linux/6857/3
    exe.linkSystemLibrary("SDL3");
    exe.linkLibC();
} else {
    const sdl_dep = b.dependency("sdl", .{
        .optimize = optimize,
        .target = target,
    });
    exe.linkLibrary(sdl_dep.artifact("SDL3"));
}

b.installArtifact(exe);
```

## Test it out

Now lets test it out and see if it creates a window.

Following codesnippet should create a window that can be exited.

```zig

const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    var window: ?*c.SDL_Window = undefined;
    var renderer: ?*c.SDL_Renderer = undefined;

    if (!c.SDL_CreateWindowAndRenderer("My Game Window", 400, 140, c.SDL_WINDOW_OPENGL, @ptrCast(&window), @ptrCast(&renderer))) {
        c.SDL_Log("Unable to create window and renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_DestroyWindow(window);
    defer c.SDL_DestroyRenderer(renderer);

    var quit = false;

    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(10);
    }
}
```
