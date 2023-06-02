include("add.jl")
include("time.jl")
include("plots_engine.jl")

println("=== START ===")

iteration = 0
initialWorkload = 10000.0
timeline = Time.Timeline(iteration, initialWorkload, 50, 150, 15.0, 100)

# currentPlot = PlotsEngine.create_plot()
# PlotsEngine.updatePlot(currentPlot, timeline)
# PlotsEngine.displayPlot(currentPlot)

while iteration < 100
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

    # PlotsEngine.updatePlot(currentPlot, timeline)
    # PlotsEngine.displayPlot(currentPlot)

    sleep(1)
end

# println(Time.getPointsIds(timeline))

println("=== END ===")