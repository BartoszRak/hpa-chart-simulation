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

struct ControlSlider
    label::String
    range::Any
    startValue::Any
    onChange::Any
end

function render(timeline::Time.Timeline, callbacks::ControlCallbacks, sliders::Array{ControlSlider}=[])
    GLMakie.activate!(title="Custom title", fxaa=false)
    f = Figure(backgroundcolor=:tomato)

    content = f[2, 1] = GridLayout()
    footer = f[3, 1] = GridLayout()

    series, x = createChart(f, content, timeline)
    createControls(footer, callbacks, sliders)

    display(f)

    rerender = () -> begin
        updateChart(timeline, series, x)
        display(f)
    end

    return rerender
end

function createChart(fig, content, timeline::Time.Timeline)
    ax = Axis(content[1, 1], height=600, width=600, xlabel="Time", yminorticksvisible=true, yminorgridvisible=true,
        yminorticks=IntervalsBetween(5))
    x = Observable([range(1, timeline.pointsLimit, length=timeline.pointsLimit)...])

    y1Data = ArrayUtils.enforceSize(Time.getPointsReplicas(timeline), timeline.pointsLimit)
    y2Data = ArrayUtils.enforceSize(Time.getPointsEfficiency(timeline), timeline.pointsLimit)
    y3Data = ArrayUtils.enforceSize(Time.getPointsWorkload(timeline), timeline.pointsLimit)
    y4Data = ArrayUtils.enforceSize(Time.getPointsAvgWorkload(timeline), timeline.pointsLimit)
    y1 = Observable(y1Data)
    y2 = Observable(y2Data)
    y3 = Observable(y3Data)
    y4 = Observable(y4Data)

    lines!(ax, x, y1, label="Current replicas", color=:green)
    lines!(ax, x, y2, label="Pods efficiency", color=:blue)
    lines!(ax, x, y3, label="Workload", color=:red)
    lines!(ax, x, y4, label="Avg workload", color=:orange)
    axislegend()

    # fig[1, 2] = Legend(content, ax, "Legend", framevisible=false)

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

function createControls(footer, callbacks::ControlCallbacks, sliders::Array{ControlSlider})
    if length(sliders) != 0
        preparedSliders = map(specificSlider -> ((label=specificSlider.label, range=specificSlider.range, startvalue=specificSlider.startValue)), sliders)
        sg = SliderGrid(footer[1, 2], #width=500,
            preparedSliders...,
            width=500
        )
        index = 1
        for specificSlider in sliders
            on(sg.sliders[index].value) do value
                specificSlider.onChange(value)
            end

            index += 1
        end
    end

    startButton = Button(footer[2, 1], label="Start")
    pauseButton = Button(footer[2, 2], label="Pause")
    stopButton = Button(footer[2, 3], label="Stop")

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