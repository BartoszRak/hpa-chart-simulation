module Visual
using ..Time
using GLMakie

struct ControlCallbacks
    onStart::Any
    onStop::Any
    onPause::Any
end

function render(timeline::Time.Timeline, callbacks::ControlCallbacks)
    GLMakie.activate!(title="Custom title", fxaa=false)
    f = Figure(backgroundcolor=:tomato)
    content = f[1, 1] = GridLayout()
    footer = f[2, 1] = GridLayout()

    createControls(footer, callbacks)

    display(f)
end

function createControls(footer, callbacks::ControlCallbacks)
    startButton = Button(footer[1, 1], label="Start")
    pauseButton = Button(footer[1, 2], label="Pause")
    stopButton = Button(footer[1, 3], label="Stop")

    if !isnothing(callbacks.onStart)
        on(startButton.clicks) do c
            callbacks.onStart()
        end
    end
    if !isnothing(callbacks.onPause)
        on(pauseButton.clicks) do c
            callbacks.onPause()
        end
    end
    if !isnothing(callbacks.onStop)
        on(stopButton.clicks) do c
            callbacks.onStop()
        end
    end
end
end