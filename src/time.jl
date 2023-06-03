
module Time
using Crayons

mutable struct TimePoint
    id::Integer
    workload::Float64
    currentReplicas::Integer
    shouldBeScaledUp::Bool
    shouldBeScaledDown::Bool
    avgWorkload::Float64

    function TimePoint(
        id::Integer,
        workload::Float64,
        currentReplicas::Integer,
        shouldBeScaledUp::Union{Bool,Nothing}=false,
        shouldBeScaledDown::Union{Bool,Nothing}=false
    )
        avgWorkload = workload / currentReplicas
        new(id, workload, currentReplicas, shouldBeScaledUp, shouldBeScaledDown, avgWorkload)
    end
end

mutable struct Timeline
    minPods::Integer
    maxPods::Integer
    podEfficiency::Float64
    targetAvgWorkload::Integer
    points::Array{TimePoint}
    scaleUpBy::Integer
    scaleDownBy::Integer
    pointsLimit::Integer
    naturalGrowth::Integer

    function Timeline(
        initialId::Integer,
        initialWorkload::Float64,
        minPods::Integer,
        maxPods::Integer,
        podEfficiency::Float64,
        targetAvgWorkload::Integer,
        scaleUpBy::Union{Integer,Nothing}=10,
        scaleDownBy::Union{Integer,Nothing}=10,
        pointsLimit::Union{Integer,Nothing}=50,
        naturalGrowth::Integer=1000
    )
        initialPoints = [
            TimePoint(initialId, initialWorkload, minPods)
        ]
        return new(minPods, maxPods, podEfficiency, targetAvgWorkload, initialPoints, scaleUpBy, scaleDownBy, pointsLimit, naturalGrowth)
    end
end

function generateNewPoint(timeline::Timeline, id::Integer)
    println(
        Crayon(foreground=:green),
        "=> Generate point",
        Crayon(reset=true)
    )
    lastPoints = getLastPoints(timeline, 4)
    singleLastPoint = last(lastPoints)
    newWorkload = singleLastPoint.workload + timeline.naturalGrowth - (timeline.podEfficiency * singleLastPoint.currentReplicas)
    shouldBeScaledUp = all(point -> begin
            doesHitTarget = point.avgWorkload > timeline.targetAvgWorkload
            println(
                Crayon(foreground=:green),
                "--- check point $(point.id): value $(point.avgWorkload) / target $(timeline.targetAvgWorkload) = $(doesHitTarget)",
                Crayon(reset=true)
            )
            doesHitTarget
        end, lastPoints)
    shouldBeScaledDown = !shouldBeScaledUp
    newReplicas = scale(timeline, shouldBeScaledUp, singleLastPoint.currentReplicas)
    return TimePoint(id, newWorkload, newReplicas, shouldBeScaledUp, shouldBeScaledDown)
end

function scaleUp(timeline::Timeline, currentReplicas::Integer)::Integer
    newReplicas = currentReplicas + timeline.scaleUpBy
    return newReplicas > timeline.maxPods ? timeline.maxPods : newReplicas
end

function scaleDown(timeline::Timeline, currentReplicas::Integer)::Integer
    newReplicas = currentReplicas - timeline.scaleDownBy
    return newReplicas < timeline.minPods ? timeline.minPods : newReplicas
end

function scale(timeline::Timeline, shouldBeScaledUp::Bool, currentReplicas::Integer)::Integer
    return shouldBeScaledUp ? scaleUp(timeline, currentReplicas) : scaleDown(timeline, currentReplicas)
end

function pushPoint(timeline::Timeline, point::TimePoint)
    push!(timeline.points, point)
    isLimitReached = length(timeline.points) > timeline.pointsLimit
    if isLimitReached
        popfirst!(timeline.points)
    end
    return timeline
end

function getPoints(timeline::Timeline)
    return timeline.points
end

function getLastPoints(timeline::Timeline, count::Integer)
    allPoints = getPoints(timeline)
    lastIndex = length(allPoints)
    firstIndex = lastIndex > count ? lastIndex - count + 1 : 1
    return allPoints[firstIndex:lastIndex]
end

function getPointsIds(timeline::Timeline)
    return map(x -> x.id, timeline.points)
end

function getPointsReplicas(timeline::Timeline)
    return map(x -> x.currentReplicas, timeline.points)
end

function getPointsEfficiency(timeline::Timeline)
    return map(x -> x.currentReplicas * timeline.podEfficiency, timeline.points)
end

function getPointsWorkload(timeline::Timeline)
    return map(x -> x.workload, timeline.points)
end

function getPointsAvgWorkload(timeline::Timeline)
    return map(x -> x.avgWorkload, timeline.points)
end

function displayPoint(point::TimePoint)
    println(Crayon(foreground=:yellow), "# Point($(point.id)) -> Workload: $(point.workload), Avg Workload: $(point.avgWorkload), Replicas: $(point.currentReplicas), UP: $(point.shouldBeScaledUp), DOWN: $(point.shouldBeScaledDown)", Crayon(reset=true))
end
end