Concept of shrinking can be used to reset the High WAter Mark  in ORACLE

What is the High Water Mark (HWM)?
The High Water Mark indicates the highest point of allocated space in a segment (e.g., a table or index) that has ever been used.
When data is deleted from a table, the space is marked as available but the HWM does not move down. 
This means the space below the HWM is allocated to the table, even if it's unused.
This unused space can affect:
Full table scans (since Oracle scans up to the HWM even if much of the space is empty).
Space management and storage efficiency.


What is Shrinking?
Shrinking is a process that allows Oracle to:

Reclaim unused space within a segment.
Adjust the High Water Mark to reflect the actual used space.
Compact the data to minimize fragmentation.

Steps to Shrink and Reset HWM
Enable Row Movement (Required): Shrinking requires enabling row movement for the table to allow Oracle to reorganize the rows.

ALTER TABLE table_name ENABLE ROW MOVEMENT;
Shrink the Table: Use the SHRINK SPACE command to compact the data and reset the HWM.

ALTER TABLE table_name SHRINK SPACE;
This operation can be performed online, meaning the table remains accessible for queries and DML during the shrink.

If you want to shrink and immediately reset the HWM without compacting the rows:

ALTER TABLE table_name SHRINK SPACE COMPACT;

Disable Row Movement (Optional): If row movement is no longer needed, you can disable it:

ALTER TABLE table_name DISABLE ROW MOVEMENT;

Impact of Shrinking
Reset High Water Mark: After shrinking, the HWM reflects the actual used space, reducing unnecessary storage allocation.

Reclaimed Space: Unused space is returned to the tablespace, making it available for other objects.

Improved Performance: Full table scans only process the data up to the new HWM, which can improve query performance.

Restrictions and Considerations

Not Supported for Index-Organized Tables (IOTs): Shrinking is only available for heap-organized tables.

LOB Columns: Tables with LOBs (Large Objects) require special considerations and additional steps.

Locks: The shrink operation may acquire locks on the segment, potentially affecting concurrent DML.

Undo and Redo: Shrinking generates undo and redo logs, so ensure sufficient undo tablespace is available.

Monitoring and Validation
You can check the HWM before and after the shrink using the DBA_SEGMENTS view:

SELECT segment_name, bytes/1024/1024 AS size_mb
FROM dba_segments
WHERE segment_name = 'EMPLOYEES';

By shrinking a table and resetting its HWM, you can optimize storage and improve query performance in Oracle.
