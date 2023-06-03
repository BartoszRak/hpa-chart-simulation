include("time.jl")
include("visual.jl")

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

rerender = Visual.render(timeline, Visual.ControlCallbacks(onStart, onStop, onPause))

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

    rerender()

    sleep(0.5)
end

println("=== END ===")