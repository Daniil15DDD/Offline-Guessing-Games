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
        TopTenList("Largest countries in the European Union", basis: "Total area.", [
            "France", "Spain", "Sweden", "Germany", "Finland",
            "Poland", "Italy", "Romania", "Greece", "Bulgaria"
        ]),
        TopTenList("Largest countries in North America", basis: "Total area, counting Central America and the Caribbean.", [
            "Canada", "United States=USA=US=America", "Mexico", "Nicaragua", "Honduras",
            "Cuba", "Guatemala", "Panama", "Costa Rica", "Dominican Republic"
        ]),
        TopTenList("Largest countries in Oceania", basis: "Land area.", [
            "Australia", "Papua New Guinea=PNG", "New Zealand", "Solomon Islands", "Fiji",
            "Vanuatu", "Samoa", "Kiribati", "Tonga", "Micronesia=Federated States of Micronesia"
        ]),
        TopTenList("Most populous countries in South America", basis: "United Nations population estimates for 2020.", [
            "Brazil", "Colombia", "Argentina", "Peru", "Venezuela",
            "Chile", "Ecuador", "Bolivia", "Paraguay", "Uruguay"
        ]),
        TopTenList("Most populous countries in Asia in 2020", basis: "United Nations population estimates for 2020.", [
            "China", "India", "Indonesia", "Pakistan", "Bangladesh",
            "Japan", "Philippines", "Vietnam", "Turkey=Turkiye", "Iran"
        ]),
        TopTenList("Most populous countries in Africa in 2020", basis: "United Nations population estimates for 2020. Several are very close together.", [
            "Nigeria", "Ethiopia", "Egypt", "DR Congo=Democratic Republic of the Congo=DRC=Congo", "Tanzania",
            "South Africa", "Kenya", "Uganda", "Algeria", "Sudan"
        ]),
        TopTenList("Smallest US states", basis: "Total area, smallest first.", [
            "Rhode Island", "Delaware", "Connecticut", "New Jersey", "New Hampshire",
            "Vermont", "Massachusetts", "Hawaii", "Maryland", "West Virginia"
        ]),
        TopTenList("First ten US states", basis: "Order in which they ratified the Constitution.", [
            "Delaware", "Pennsylvania", "New Jersey", "Georgia", "Connecticut",
            "Massachusetts", "Maryland", "South Carolina", "New Hampshire", "Virginia"
        ]),
        TopTenList("Newest US states", basis: "Order of joining the Union, most recent first.", [
            "Hawaii", "Alaska", "Arizona", "New Mexico", "Oklahoma",
            "Utah", "Wyoming", "Idaho", "Washington", "Montana"
        ]),
        TopTenList("US presidents 11 to 20", basis: "Order in which they took office.", [
            "James Polk=Polk=James K. Polk", "Zachary Taylor=Taylor", "Millard Fillmore=Fillmore",
            "Franklin Pierce=Pierce", "James Buchanan=Buchanan", "Abraham Lincoln=Lincoln",
            "Andrew Johnson=Johnson", "Ulysses Grant=Grant=Ulysses S. Grant",
            "Rutherford Hayes=Hayes=Rutherford B. Hayes", "James Garfield=Garfield"
        ]),
        TopTenList("US presidents 35 to 44", basis: "Order in which they took office, from 1961 to 2009.", [
            "John Kennedy=Kennedy=JFK=John F. Kennedy", "Lyndon Johnson=Johnson=LBJ=Lyndon B. Johnson",
            "Richard Nixon=Nixon", "Gerald Ford=Ford", "Jimmy Carter=Carter", "Ronald Reagan=Reagan",
            "George H. W. Bush=Bush senior=George Bush senior=HW Bush=Bush",
            "Bill Clinton=Clinton", "George W. Bush=Bush junior=George Bush junior=W Bush",
            "Barack Obama=Obama"
        ]),
        TopTenList("Elements 11 to 20", basis: "Order in the periodic table, by atomic number.", [
            "Sodium", "Magnesium", "Aluminium=Aluminum", "Silicon", "Phosphorus",
            "Sulfur=Sulphur", "Chlorine", "Argon", "Potassium", "Calcium"
        ]),
        TopTenList("Elements in the Earth's crust", basis: "Share of the crust by mass, largest first.", [
            "Oxygen", "Silicon", "Aluminium=Aluminum", "Iron", "Calcium",
            "Sodium", "Magnesium", "Potassium", "Titanium", "Hydrogen"
        ]),
        TopTenList("Elements in the universe", basis: "Share of ordinary matter by mass, largest first.", [
            "Hydrogen", "Helium", "Oxygen", "Carbon", "Neon",
            "Iron", "Nitrogen", "Silicon", "Magnesium", "Sulfur=Sulphur"
        ]),
        TopTenList("Gases in the air", basis: "Share of dry air by volume, largest first.", [
            "Nitrogen", "Oxygen", "Argon", "Carbon dioxide=CO2", "Neon",
            "Helium", "Methane", "Krypton", "Hydrogen", "Nitrous oxide=Laughing gas"
        ]),
        TopTenList("First ten prime numbers", basis: "Smallest first.", [
            "2=Two", "3=Three", "5=Five", "7=Seven", "11=Eleven",
            "13=Thirteen", "17=Seventeen", "19=Nineteen", "23=Twenty-three", "29=Twenty-nine"
        ]),
        TopTenList("First ten powers of two", basis: "Starting from 2, doubling each time.", [
            "2=Two", "4=Four", "8=Eight", "16=Sixteen", "32=Thirty-two",
            "64=Sixty-four", "128", "256", "512", "1024=1,024"
        ]),
        TopTenList("Summer Olympic host cities, 1948 to 1984", basis: "In order, one Games every four years.", [
            "London", "Helsinki", "Melbourne", "Rome", "Tokyo",
            "Mexico City", "Munich", "Montreal", "Moscow", "Los Angeles=LA"
        ]),
        TopTenList("First ten football World Cup hosts", basis: "Men's World Cups from 1930 to 1974, in order.", [
            "Uruguay", "Italy", "France", "Brazil", "Switzerland",
            "Sweden", "Chile", "England", "Mexico", "West Germany=Germany"
        ]),
        TopTenList("Largest Canadian cities", basis: "City population in the 2021 census.", [
            "Toronto", "Montreal", "Calgary", "Ottawa", "Edmonton",
            "Winnipeg", "Mississauga", "Vancouver", "Brampton", "Hamilton"
        ]),
        TopTenList("Most populous Canadian provinces", basis: "2021 census.", [
            "Ontario", "Quebec", "British Columbia=BC", "Alberta", "Manitoba",
            "Saskatchewan", "Nova Scotia", "New Brunswick", "Newfoundland and Labrador=Newfoundland",
            "Prince Edward Island=PEI"
        ]),
        TopTenList("Largest Italian cities", basis: "City population.", [
            "Rome", "Milan", "Naples", "Turin", "Palermo",
            "Genoa", "Bologna", "Florence", "Bari", "Catania"
        ]),
        TopTenList("Largest German cities", basis: "City population. Leipzig, Dortmund and Essen are close together.", [
            "Berlin", "Hamburg", "Munich", "Cologne", "Frankfurt",
            "Stuttgart", "Dusseldorf", "Leipzig", "Dortmund", "Essen"
        ]),
        TopTenList("Most populous German states", basis: "Population, largest first.", [
            "North Rhine-Westphalia=NRW", "Bavaria", "Baden-Wurttemberg", "Lower Saxony", "Hesse",
            "Rhineland-Palatinate", "Saxony", "Berlin", "Schleswig-Holstein", "Brandenburg"
        ]),
        TopTenList("Largest objects in the Solar System", basis: "Diameter.", [
            "Sun=The Sun", "Jupiter", "Saturn", "Uranus", "Neptune",
            "Earth", "Venus", "Mars", "Ganymede", "Titan"
        ])
    ]
}
