module Visual
using ..Time
using GLMakie
using Makie
include("array_utils.jl")


struct ControlCallbacks
    onStart::Any
    onStop::Any
    onPause::Any
end

function render(timeline::Time.Timeline, callbacks::ControlCallbacks)
    GLMakie.activate!(title="Custom title", fxaa=false)
    f = Figure(backgroundcolor=:tomato)

    content = f[2, 1] = GridLayout()
    footer = f[3, 1] = GridLayout()

    series, x = createChart(content, timeline)
    createControls(footer, callbacks)

    display(f)

    rerender = () -> begin
        updateChart(timeline, series, x)
        display(f)
    end

    return rerender
end

function createChart(content, timeline::Time.Timeline)
    ax = Axis(content[1, 1], height=400, width=400, xlabel="Time")
    x = Observable([range(1, timeline.pointsLimit, length=timeline.pointsLimit)...])

    y1Data = ArrayUtils.enforceSize(Time.getPointsReplicas(timeline), timeline.pointsLimit)
    y2Data = ArrayUtils.enforceSize(Time.getPointsEfficiency(timeline), timeline.pointsLimit)
    y3Data = ArrayUtils.enforceSize(Time.getPointsWorkload(timeline), timeline.pointsLimit)
    y4Data = ArrayUtils.enforceSize(Time.getPointsAvgWorkload(timeline), timeline.pointsLimit)
    y1 = Observable(y1Data)
    y2 = Observable(y2Data)
    y3 = Observable(y3Data)
    y4 = Observable(y4Data)

    lines!(ax, x, y1)
    lines!(ax, x, y2)
    lines!(ax, x, y3)
    lines!(ax, x, y4)

    return (y1, y2, y3, y4), x
end

function updateChart(timeline::Time.Timeline, series::Any, x::Any)
    y1, y2, y3, y4 = series
    y1Data = ArrayUtils.enforceSize(Time.getPointsReplicas(timeline), timeline.pointsLimit)
    y2Data = ArrayUtils.enforceSize(Time.getPointsEfficiency(timeline), timeline.pointsLimit)
    y3Data = ArrayUtils.enforceSize(Time.getPointsWorkload(timeline), timeline.pointsLimit)
    y4Data = ArrayUtils.enforceSize(Time.getPointsAvgWorkload(timeline), timeline.pointsLimit)

    y1[] = y1Data
    y2[] = y2Data
    y3[] = y3Data
    y4[] = y4Data


    pointsIds = Time.getPointsIds(timeline)
    if length(pointsIds) >= timeline.pointsLimit
        adjustedPointsIds = ArrayUtils.enforceSize(pointsIds, timeline.pointsLimit)
        x[] = adjustedPointsIds
    end
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