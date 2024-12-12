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
