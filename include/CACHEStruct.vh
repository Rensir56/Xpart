`ifndef __CACHE_STRUCT__
`define __CACHE_STRUCT__

package CACHEStruct;

    localparam ADDR_WIDTH = 64,
               DATA_WIDTH = 64,
               BANK_NUM   = 4,
               CAPACITY   = 1024,
               BYTE_NUM = DATA_WIDTH / 8,
               LINE_NUM = CAPACITY / 2 / (BANK_NUM * BYTE_NUM),
               GRANU_LEN = $clog2(BYTE_NUM),
               GRANU_BEGIN = 0,
               GRANU_END = GRANU_BEGIN + GRANU_LEN - 1,
               OFFSET_LEN = $clog2(BANK_NUM),
               OFFSET_BEGIN = GRANU_END + 1,
               OFFSET_END = OFFSET_BEGIN + OFFSET_LEN - 1,
               INDEX_LEN = $clog2(LINE_NUM),
               INDEX_BEGIN = OFFSET_END + 1,
               INDEX_END = INDEX_BEGIN + INDEX_LEN - 1,
               TAG_BEGIN = INDEX_END + 1,
               TAG_END = ADDR_WIDTH - 1,
               TAG_LEN = ADDR_WIDTH - TAG_BEGIN;

    typedef logic [TAG_LEN-1:0] tag_t;
    typedef logic [INDEX_LEN-1:0] index_t;
    typedef logic [OFFSET_LEN-1:0] offset_t;
    typedef logic [BANK_NUM*DATA_WIDTH-1:0] data_t;

    typedef struct {
        logic  valid;
        logic  dirty;
        logic  lru;
        tag_t  tag;
        data_t data;
    } CacheLine;

endpackage

`endif

