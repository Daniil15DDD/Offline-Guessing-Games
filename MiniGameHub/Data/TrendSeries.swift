import Foundation

struct TrendSeries: Equatable {
    let title: String
    let unit: String
    let source: String
    let years: [Int]
    let values: [Double]
    /// How many points are shown before the player takes over.
    let shown: Int
    /// Fixed vertical range of the chart, chosen so the axis does not give
    /// the ending away.
    let axisMin: Double
    let axisMax: Double

    var hiddenCount: Int { values.count - shown }
}

/// Charts for Trendline. All figures are official published statistics,
/// rounded as shown.
enum TrendSeriesData {
    static let all: [TrendSeries] = [
        TrendSeries(
            title: "World population",
            unit: "billion people",
            source: "United Nations population estimates",
            years: [1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [2.50, 2.75, 3.02, 3.34, 3.70, 4.07, 4.44, 4.86, 5.32, 5.74, 6.15, 6.56, 6.99, 7.43, 7.84],
            shown: 7, axisMin: 0, axisMax: 12
        ),
        TrendSeries(
            title: "Population of the United States",
            unit: "million people",
            source: "US census, every ten years",
            years: [1900, 1910, 1920, 1930, 1940, 1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020],
            values: [76.2, 92.2, 106.0, 123.2, 132.2, 151.3, 179.3, 203.2, 226.5, 248.7, 281.4, 308.7, 331.4],
            shown: 6, axisMin: 0, axisMax: 500
        ),
        TrendSeries(
            title: "Population of India",
            unit: "million people",
            source: "Census of India, every ten years",
            years: [1901, 1911, 1921, 1931, 1941, 1951, 1961, 1971, 1981, 1991, 2001, 2011],
            values: [238.4, 252.1, 251.3, 279.0, 318.7, 361.1, 439.2, 548.2, 683.3, 846.4, 1028.7, 1210.9],
            shown: 6, axisMin: 0, axisMax: 1600
        ),
        TrendSeries(
            title: "Population of Japan",
            unit: "million people",
            source: "Census of Japan, every five years",
            years: [1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [84.1, 90.1, 94.3, 99.2, 104.7, 111.9, 117.1, 121.0, 123.6, 125.6, 126.9, 127.8, 128.1, 127.1, 126.1],
            shown: 7, axisMin: 60, axisMax: 180
        ),
        TrendSeries(
            title: "Carbon dioxide in the air",
            unit: "parts per million",
            source: "Yearly average measured at Mauna Loa, Hawaii",
            years: [1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [316.9, 320.0, 325.7, 331.1, 338.8, 346.1, 354.4, 360.8, 369.6, 379.8, 389.9, 400.8, 414.2],
            shown: 6, axisMin: 300, axisMax: 460
        ),
        TrendSeries(
            title: "Share of people living in towns and cities",
            unit: "percent of the world",
            source: "United Nations urbanisation estimates",
            years: [1950, 1960, 1970, 1980, 1990, 2000, 2010, 2020],
            values: [29.6, 33.6, 36.6, 39.3, 43.0, 46.7, 51.7, 56.2],
            shown: 4, axisMin: 0, axisMax: 100
        ),
        TrendSeries(
            title: "Members of the United Nations",
            unit: "countries",
            source: "United Nations membership records",
            years: [1945, 1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [51, 60, 76, 99, 117, 127, 144, 154, 159, 159, 185, 189, 191, 192, 193, 193],
            shown: 7, axisMin: 0, axisMax: 300
        ),
        TrendSeries(
            title: "Members of the European Union",
            unit: "countries",
            source: "Including its forerunner, the European Economic Community",
            years: [1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [6, 6, 6, 9, 9, 10, 12, 15, 15, 25, 27, 28, 27],
            shown: 7, axisMin: 0, axisMax: 40
        ),
        TrendSeries(
            title: "Men's 100 metres world record",
            unit: "seconds",
            source: "Official record standing at the end of each year",
            years: [1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [9.95, 9.95, 9.95, 9.93, 9.92, 9.85, 9.79, 9.77, 9.58, 9.58, 9.58],
            shown: 5, axisMin: 9.2, axisMax: 10.1
        ),
        TrendSeries(
            title: "US federal minimum wage",
            unit: "dollars per hour, not adjusted for inflation",
            source: "US Department of Labor",
            years: [1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020],
            values: [0.75, 0.75, 1.00, 1.25, 1.60, 2.10, 3.10, 3.35, 3.80, 4.25, 5.15, 5.15, 7.25, 7.25, 7.25],
            shown: 7, axisMin: 0, axisMax: 12
        )
    ]
}
