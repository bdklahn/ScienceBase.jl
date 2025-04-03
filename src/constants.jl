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
