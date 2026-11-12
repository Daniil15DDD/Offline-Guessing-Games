import Foundation

struct TopTenEntry: Equatable {
    /// The first spelling is the one shown. The rest are also accepted.
    let spellings: [String]
    var name: String { spellings[0] }
}

struct TopTenList: Equatable {
    let title: String
    /// What the ranking is based on.
    let basis: String
    /// Rank 1 first.
    let entries: [TopTenEntry]

    init(_ title: String, basis: String, _ entries: [String]) {
        self.title = title
        self.basis = basis
        self.entries = entries.map { text in
            TopTenEntry(spellings: text.split(separator: "=").map(String.init))
        }
    }
}

/// Lists for Ten Count. They are limited to rankings that are well
/// established and do not change from year to year.
enum TopTenLists {
    static let all: [TopTenList] = [
        TopTenList("Largest countries", basis: "Total area. Sources differ on whether China or the United States is third.", [
            "Russia", "Canada", "China", "United States=USA=US=America", "Brazil",
            "Australia", "India", "Argentina", "Kazakhstan", "Algeria"
        ]),
        TopTenList("Most populous countries in 2020", basis: "United Nations population estimates for 2020.", [
            "China", "India", "United States=USA=US=America", "Indonesia", "Pakistan",
            "Brazil", "Nigeria", "Bangladesh", "Russia", "Mexico"
        ]),
        TopTenList("Longest rivers", basis: "Length of the whole river system.", [
            "Nile", "Amazon", "Yangtze=Chang Jiang", "Mississippi=Mississippi-Missouri=Missouri",
            "Yenisei=Yenisey", "Yellow River=Yellow=Huang He", "Ob=Ob-Irtysh=Irtysh",
            "Parana=Rio de la Plata", "Congo=Zaire", "Amur=Heilong"
        ]),
        TopTenList("Highest mountains", basis: "Height of the summit above sea level.", [
            "Everest=Mount Everest", "K2", "Kangchenjunga", "Lhotse", "Makalu",
            "Cho Oyu", "Dhaulagiri", "Manaslu", "Nanga Parbat", "Annapurna"
        ]),
        TopTenList("Largest US states", basis: "Total area.", [
            "Alaska", "Texas", "California", "Montana", "New Mexico",
            "Arizona", "Nevada", "Colorado", "Oregon", "Wyoming"
        ]),
        TopTenList("Most populous US states", basis: "2020 census.", [
            "California", "Texas", "Florida", "New York", "Pennsylvania",
            "Illinois", "Ohio", "Georgia", "North Carolina", "Michigan"
        ]),
        TopTenList("First ten elements", basis: "Order in the periodic table, by atomic number.", [
            "Hydrogen", "Helium", "Lithium", "Beryllium", "Boron",
            "Carbon", "Nitrogen", "Oxygen", "Fluorine", "Neon"
        ]),
        TopTenList("Largest lakes", basis: "Surface area.", [
            "Caspian Sea=Caspian", "Superior=Lake Superior", "Victoria=Lake Victoria",
            "Huron=Lake Huron", "Michigan=Lake Michigan", "Tanganyika=Lake Tanganyika",
            "Baikal=Lake Baikal", "Great Bear Lake=Great Bear", "Malawi=Lake Malawi=Nyasa",
            "Great Slave Lake=Great Slave"
        ]),
        TopTenList("Largest islands", basis: "Area. Continents such as Australia are not counted.", [
            "Greenland", "New Guinea=Papua", "Borneo=Kalimantan", "Madagascar",
            "Baffin Island=Baffin", "Sumatra", "Honshu", "Victoria Island=Victoria",
            "Great Britain=Britain", "Ellesmere Island=Ellesmere"
        ]),
        TopTenList("First ten US presidents", basis: "Order in which they took office.", [
            "George Washington=Washington", "John Adams=Adams", "Thomas Jefferson=Jefferson",
            "James Madison=Madison", "James Monroe=Monroe",
            "John Quincy Adams=Quincy Adams=JQ Adams", "Andrew Jackson=Jackson",
            "Martin Van Buren=Van Buren", "William Henry Harrison=Harrison=William Harrison",
            "John Tyler=Tyler"
        ]),
        TopTenList("Largest moons", basis: "Diameter, across the whole Solar System.", [
            "Ganymede", "Titan", "Callisto", "Io", "Moon=The Moon=Luna",
            "Europa", "Triton", "Titania", "Rhea", "Oberon"
        ]),
        TopTenList("Brightest stars in the night sky", basis: "Apparent brightness seen from Earth. The Sun is not counted.", [
            "Sirius", "Canopus", "Alpha Centauri=Rigil Kentaurus", "Arcturus", "Vega",
            "Capella", "Rigel", "Procyon", "Achernar", "Betelgeuse"
        ]),
        TopTenList("Largest countries in Africa", basis: "Total area.", [
            "Algeria", "DR Congo=Democratic Republic of the Congo=DRC=Congo", "Sudan", "Libya", "Chad",
            "Niger", "Angola", "Mali", "South Africa", "Ethiopia"
        ]),
        TopTenList("Largest countries in South America", basis: "Total area.", [
            "Brazil", "Argentina", "Peru", "Colombia", "Bolivia",
            "Venezuela", "Chile", "Paraguay", "Ecuador", "Guyana"
        ]),
        TopTenList("Largest countries in Asia", basis: "Total area. Russia is not counted.", [
            "China", "India", "Kazakhstan", "Saudi Arabia", "Indonesia",
            "Iran", "Mongolia", "Pakistan", "Turkey=Turkiye", "Myanmar=Burma"
        ]),
        TopTenList("Largest US cities", basis: "City population in the 2020 census.", [
            "New York=New York City=NYC", "Los Angeles=LA", "Chicago", "Houston", "Phoenix",
            "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose"
        ]),
        TopTenList("Largest Canadian provinces and territories", basis: "Total area.", [
            "Nunavut", "Quebec", "Northwest Territories=NWT", "Ontario", "British Columbia=BC",
            "Alberta", "Saskatchewan", "Manitoba", "Yukon", "Newfoundland and Labrador=Newfoundland"
        ]),
        TopTenList("First ten Greek letters", basis: "Alphabetical order.", [
            "Alpha", "Beta", "Gamma", "Delta", "Epsilon",
            "Zeta", "Eta", "Theta", "Iota", "Kappa"
        ]),
        TopTenList("Mohs hardness scale", basis: "The ten reference minerals, softest first.", [
            "Talc", "Gypsum", "Calcite", "Fluorite", "Apatite",
            "Orthoclase=Feldspar", "Quartz", "Topaz", "Corundum", "Diamond"
        ]),
        TopTenList("Elements in the human body", basis: "Share of body mass, largest first.", [
            "Oxygen", "Carbon", "Hydrogen", "Nitrogen", "Calcium",
            "Phosphorus", "Potassium", "Sulfur=Sulphur", "Sodium", "Chlorine"
        ]),
        TopTenList("Largest objects in the Solar System", basis: "Diameter.", [
            "Sun=The Sun", "Jupiter", "Saturn", "Uranus", "Neptune",
            "Earth", "Venus", "Mars", "Ganymede", "Titan"
        ])
    ]
}
