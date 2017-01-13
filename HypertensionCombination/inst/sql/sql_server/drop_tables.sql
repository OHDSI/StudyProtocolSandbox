IF OBJECT_ID('@resultsDatabaseSchema.@exposureTable', 'U') IS NOT NULL
	DROP TABLE @resultsDatabaseSchema.@exposureTable;
IF OBJECT_ID('@resultsDatabaseSchema.@outcomeTable', 'U') IS NOT NULL
	DROP TABLE @resultsDatabaseSchema.@outcomeTable;
