
module PlotsEngine

using Plots
using ..Time

function create_plot()::Plots.Plot
    # xs = range(0, 2π, length = 10)
    # data = [sin.(xs) cos.(xs) 2sin.(xs) 2cos.(xs)]
    # println("xs $xs")
    # println("data $data")
    # gr(show=true)
    # x = []
    # println(x)
    # y = []
    # println(y)
    # return plot(x, y)
    gr(show=true)
    # x = [1, 2, 3, 4, 5]  # x-values for the series
    # y1 = [10, 15, 8, 12, 6]  # y-values for the first series
    # y2 = [5, 8, 6, 10, 15]  # y-values for the second series
    # plt = plot(x, y1, label = "Series1", linestyle = :solid, marker = :circle)
    # plot!(plt, x, y2, label = "Series2", linestyle = :dash, marker = :square)
    plt = plot()
    return plt
end

function updatePlot(plt::Plots.Plot, timeline::Time.Timeline)
    cleanupPlot(plt)
    x = Time.getPointsIds(timeline)
    y1 = Time.getPointsReplicas(timeline)
    y2 = Time.getPointsEfficiency(timeline)
    y3 = Time.getPointsWorkload(timeline)
    y4 = Time.getPointsAvgWorkload(timeline)
    data = [y1,y2,y3,y4]
    labels = ["Replicas" "Efficiency" "Workload" "Avg Workload"]
    colors = [:red :green :blue :yellow]
    # plot!(plt, x, y1, label="Replicas", linestyle=:solid, marker=:circle, legend=true, color=:red)
    # plot!(plt, x, y2, label="Efficiency", linestyle=:solid, marker=:circle, legend=true, color=:green)
    plot!(plt, x, data, label=labels, linestyle=:solid, marker=:circle, legend=true, color=colors, yaxis=:log)

end


function cleanupPlot(plt::Plots.Plot)
    plot!(plt, legend=false)
end

function displayPlot(plt::Plots.Plot)
    display(plt)
end
end