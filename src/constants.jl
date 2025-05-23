"Main domain"
const domain = "www.sciencebase.gov"

@enum Endpoint catalog

"main endpoint for ScienceBase data catalog"
catalog

@enum ObjectType item file

"The main container for ScienceBase data. These can point to files, have parents, children, and metadata."
item

"A file type object. This can be a child of an item. This can be a file in the ScienceBase catalog or an external link."
file

"sciencebase.gov USGS ScienceBase-Catalog ROOT item ID"
const ScienceBase_root_item_ID = "4f4e4760e4b07f02db47df9b"

"ScienceBase Catalog item ID"
const ScienceBaseCatalog_item_ID = "4f4e4760e4b07f02db47df9c"

"National Minerals Information Center item ID"
const NMIC_item_ID = "5c8c03e4e4b0938824529f7d"

"Item ID for Mineral Commodity Summaries 2025 Data Release"
const MSC_2025_item_ID = "677eaf95d34e760b392c4970"

"Mineral Commodity Summaries 2025 - World Production, Capacity, and Reserves Commodity Data Release"
const MSC_2025_World_Data_item_ID = "6798fd34d34ea8c18376e8ee"

"USGS Publications Warehouse domain"
const pubs_domain = "pubs.usgs.gov"

"Mineral Commodity Summaries 2025 publication"
const MSC_2025_pub_pdf = joinpath(pubs_domain, "periodicals/mcs2025/mcs2025.pdf")

"Mineral Commodity Summaries 2024 publication"
const MSC_2024_pub_pdf = joinpath(pubs_domain, "periodicals/mcs2024/mcs2024.pdf")

"Mineral Commodity Summaries 2024 publication"
const MSC_2023_pub_pdf = joinpath(pubs_domain, "periodicals/mcs2023/mcs2023.pdf")
