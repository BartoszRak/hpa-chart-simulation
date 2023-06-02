include("add.jl")
include("time.jl")
include("plots_engine.jl")
include("visual.jl")

# using GLMakie
# GLMakie.activate!(title = "Custom title", fxaa = false)
# f = Figure(backgroundcolor = :tomato)
# scene = Scene(backgroundcolor=:gray)
# subwindow = Scene(scene, px_area=Rect(100, 100, 200, 200), clear=true, backgroundcolor=:white)
# display(f)

println("=== START ===")

paused = false
iteration = 0
initialWorkload = 10000.0
timeline = Time.Timeline(iteration, initialWorkload, 50, 150, 15.0, 100)

function onStart()
    println("!!! START")
    if paused == true
        global paused = false
    end
end

function onStop()
    println("!!! STOP")
    exit(0)
end

function onPause()
    println("!!! PAUSE")
    global paused = true
end

Visual.render(timeline, Visual.ControlCallbacks(onStart, onStop, onPause))

while iteration < 100
    if paused
        sleep(0.5)
        continue
    end
    global iteration += 1
    pointsCount = length(Time.getPoints(timeline))
    println("###############################################################")
    println("--- ID: $(iteration) / points count: $(pointsCount)")

    newPoint = Time.generateNewPoint(timeline, iteration, 1000)
    Time.displayPoint(newPoint)
    Time.pushPoint(timeline, newPoint)

    currentPlot = PlotsEngine.create_plot()
    PlotsEngine.updatePlot(currentPlot, timeline)
    PlotsEngine.displayPlot(currentPlot)

    sleep(1)
end

println("=== END ===")