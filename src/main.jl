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

sliders = [
    Visual.ControlSlider(
        "Pod efficiency",
        20:10:500,
        20,
        value -> timeline.podEfficiency = value
    ),
    Visual.ControlSlider(
        "Natural growth",
        100:100:10000,
        1000,
        value -> timeline.naturalGrowth = value
    ),
    Visual.ControlSlider(
        "Min. pods",
        50:1:300,
        50,
        value -> timeline.minPods = value
    ),
    Visual.ControlSlider(
        "Max. pods",
        50:1:300,
        150,
        value -> timeline.maxPods = value
    )
]

rerender = Visual.render(timeline, Visual.ControlCallbacks(onStart, onStop, onPause), sliders)

while true
    if paused
        sleep(0.5)
        continue
    end
    global iteration += 1
    pointsCount = length(Time.getPoints(timeline))
    println("###############################################################")
    println("--- ID: $(iteration) / points count: $(pointsCount)")

    newPoint = Time.generateNewPoint(timeline, iteration)
    Time.displayPoint(newPoint)
    Time.pushPoint(timeline, newPoint)

    rerender()

    sleep(0.5)
end

println("=== END ===")