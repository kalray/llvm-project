; RUN: llc -verify-machineinstrs %s -o /dev/null
; Not breaking the compiler is good enough.

target triple = "kvx-kalray-cos"

%struct._reent.13.42.71.1782.1811.1956 = type { i32, %struct.__sFILE.5.34.63.1774.1803.1948*, %struct.__sFILE.5.34.63.1774.1803.1948*, %struct.__sFILE.5.34.63.1774.1803.1948*, i32, [25 x i8], i32, %struct.__locale_t.6.35.64.1775.1804.1949*, i32, void (%struct._reent.13.42.71.1782.1811.1956*)*, %struct._Bigint.7.36.65.1776.1805.1950*, i32, %struct._Bigint.7.36.65.1776.1805.1950*, %struct._Bigint.7.36.65.1776.1805.1950**, i32, ptr, %union.anon.1.9.38.67.1778.1807.1952, %struct._atexit.11.40.69.1780.1809.1954*, %struct._atexit.11.40.69.1780.1809.1954, void (i32)**, %struct._glue.12.41.70.1781.1810.1955, [8 x i8], [3 x %struct.__sFILE.5.34.63.1774.1803.1948] }
%struct.__sFILE.5.34.63.1774.1803.1948 = type { ptr, i32, i32, i16, i16, %struct.__sbuf.0.29.58.1769.1798.1943, i32, ptr, i32 (%struct._reent.13.42.71.1782.1811.1956*, ptr, ptr, i32)*, i32 (%struct._reent.13.42.71.1782.1811.1956*, ptr, ptr, i32)*, i64 (%struct._reent.13.42.71.1782.1811.1956*, ptr, i64, i32)*, i32 (%struct._reent.13.42.71.1782.1811.1956*, ptr )*, %struct.__sbuf.0.29.58.1769.1798.1943, ptr, i32, [3 x i8], [1 x i8], %struct.__sbuf.0.29.58.1769.1798.1943, i32, i64, %struct._reent.13.42.71.1782.1811.1956*, [32 x i8], %struct.__lock.2.31.60.1771.1800.1945, %struct._mbstate_t.4.33.62.1773.1802.1947, i32, [52 x i8] }
%struct.__sbuf.0.29.58.1769.1798.1943 = type { ptr, i32 }
%struct.__lock.2.31.60.1771.1800.1945 = type { %union.__cos_recursive_lock.1.30.59.1770.1799.1944, [56 x i8] }
%union.__cos_recursive_lock.1.30.59.1770.1799.1944 = type { i64 }
%struct._mbstate_t.4.33.62.1773.1802.1947 = type { i32, %union.anon.0.3.32.61.1772.1801.1946 }
%union.anon.0.3.32.61.1772.1801.1946 = type { i32 }
%struct.__locale_t.6.35.64.1775.1804.1949 = type opaque
%struct._Bigint.7.36.65.1776.1805.1950 = type { %struct._Bigint.7.36.65.1776.1805.1950*, i32, i32, i32, i32, [1 x i32] }
%union.anon.1.9.38.67.1778.1807.1952 = type { %struct.anon.3.8.37.66.1777.1806.1951 }
%struct.anon.3.8.37.66.1777.1806.1951 = type { [30 x ptr ], [30 x i32] }
%struct._atexit.11.40.69.1780.1809.1954 = type { %struct._atexit.11.40.69.1780.1809.1954*, i32, [32 x void ()*], %struct._on_exit_args.10.39.68.1779.1808.1953 }
%struct._on_exit_args.10.39.68.1779.1808.1953 = type { [32 x ptr ], [32 x ptr ], i32, i32 }
%struct._glue.12.41.70.1781.1810.1955 = type { %struct._glue.12.41.70.1781.1810.1955*, i32, %struct.__sFILE.5.34.63.1774.1803.1948* }
%struct.binding.17.46.75.1786.1815.1960 = type { i32, i32, %struct.term.16.45.74.1785.1814.1959*, %struct.binding.17.46.75.1786.1815.1960*, %struct.binding.17.46.75.1786.1815.1960* }
%struct.term.16.45.74.1785.1814.1959 = type { i32, %union.anon.15.44.73.1784.1813.1958, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, i32 }
%union.anon.15.44.73.1784.1813.1958 = type { %struct.LIST_HELP.14.43.72.1783.1812.1957* }
%struct.LIST_HELP.14.43.72.1783.1812.1957 = type { %struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr }
%struct.MEMORY_BIGBLOCKHEADERHELP.18.47.76.1787.1816.1961 = type { %struct.MEMORY_BIGBLOCKHEADERHELP.18.47.76.1787.1816.1961*, %struct.MEMORY_BIGBLOCKHEADERHELP.18.47.76.1787.1816.1961* }
%struct.MEMORY_RESOURCEHELP.19.48.77.1788.1817.1962 = type { ptr, ptr, ptr, ptr, i32, i32, i32 }
%struct.CLAUSE_HELP.21.50.79.1790.1819.1964 = type { i32, i32, i32, i32, ptr, i32, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, i32, %struct.LITERAL_HELP.20.49.78.1789.1818.1963**, i32, i32, i32, i32 }
%struct.LITERAL_HELP.20.49.78.1789.1818.1963 = type { i32, i32, i32, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.term.16.45.74.1785.1814.1959* }
%struct.subst.22.51.80.1791.1820.1965 = type { %struct.subst.22.51.80.1791.1820.1965*, i32, %struct.term.16.45.74.1785.1814.1959* }
%struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967 = type { %struct.st.23.52.81.1792.1821.1966*, [3001 x %struct.term.16.45.74.1785.1814.1959*], [4000 x %struct.term.16.45.74.1785.1814.1959*], i32 }
%struct.st.23.52.81.1792.1821.1966 = type { %struct.subst.22.51.80.1791.1820.1965*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i16, i16 }
%struct.PROOFSEARCH_HELP.27.56.85.1796.1825.1970 = type { %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr, ptr, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969 = type { %struct.st.23.52.81.1792.1821.1966*, [4000 x %struct.NODE_HELP.25.54.83.1794.1823.1968*], %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32 }
%struct.NODE_HELP.25.54.83.1794.1823.1968 = type { %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, i32, i32, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32 }
%struct.DEF_HELP.28.57.86.1797.1826.1971 = type { %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr, i32, i32 }

@_impure_ptr = external dso_local local_unnamed_addr global %struct._reent.13.42.71.1782.1811.1956*, align 8
@.str = external dso_local unnamed_addr constant [31 x i8], align 1
@.str.1 = external dso_local unnamed_addr constant [79 x i8], align 1
@.str.2 = external dso_local unnamed_addr constant [48 x i8], align 1
@.str.3 = external dso_local unnamed_addr constant [133 x i8], align 1
@.str.4 = external dso_local unnamed_addr constant [45 x i8], align 1
@.str.5 = external dso_local unnamed_addr constant [57 x i8], align 1
@.str.6 = external dso_local unnamed_addr constant [41 x i8], align 1
@.str.7 = external dso_local unnamed_addr constant [41 x i8], align 1
@.str.8 = external dso_local unnamed_addr constant [41 x i8], align 1
@cont_LEFTCONTEXT = external dso_local local_unnamed_addr global %struct.binding.17.46.75.1786.1815.1960*, align 8
@memory_OFFSET = external dso_local local_unnamed_addr global i32, align 4
@memory_BIGBLOCKS = external dso_local local_unnamed_addr global %struct.MEMORY_BIGBLOCKHEADERHELP.18.47.76.1787.1816.1961*, align 8
@memory_MARKSIZE = external dso_local local_unnamed_addr global i32, align 4
@memory_FREEDBYTES = external dso_local local_unnamed_addr global i64, align 8
@memory_MAXMEM = external dso_local local_unnamed_addr global i64, align 8
@memory_ARRAY = external dso_local local_unnamed_addr global [0 x %struct.MEMORY_RESOURCEHELP.19.48.77.1788.1817.1962*], align 8
@memory_ALIGN = external dso_local local_unnamed_addr constant i32, align 4
@cont_BINDINGS = external dso_local local_unnamed_addr global i32, align 4
@cont_LASTBINDING = external dso_local local_unnamed_addr global %struct.binding.17.46.75.1786.1815.1960*, align 8
@cont_CURRENTBINDING = external dso_local local_unnamed_addr global %struct.binding.17.46.75.1786.1815.1960*, align 8
@cont_STACKPOINTER = external dso_local local_unnamed_addr global i32, align 4
@cont_INDEXVARSCANNER = external dso_local local_unnamed_addr global i32, align 4
@fol_EQUALITY = external dso_local local_unnamed_addr global i32, align 4
@fol_NOT = external dso_local local_unnamed_addr global i32, align 4
@symbol_TYPEMASK = external dso_local local_unnamed_addr constant i32, align 4
@stack_POINTER = external dso_local local_unnamed_addr global i32, align 4
@stack_STACK = external dso_local local_unnamed_addr global [10000 x ptr ], align 8
@cont_RIGHTCONTEXT = external dso_local local_unnamed_addr global %struct.binding.17.46.75.1786.1815.1960*, align 8
@.str.9 = external dso_local unnamed_addr constant [3 x i8], align 1
@clause_CLAUSECOUNTER = external dso_local local_unnamed_addr global i32, align 4
@.str.10 = external dso_local unnamed_addr constant [46 x i8], align 1
@.str.11 = external dso_local unnamed_addr constant [51 x i8], align 1
@.str.12 = external dso_local unnamed_addr constant [54 x i8], align 1

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_EqualityResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, ptr, ptr ) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, ptr nocapture) #1

declare dso_local i32 @clause_HasSolvedConstraint(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local void @cont_Check() local_unnamed_addr #0

declare dso_local i32 @unify_UnifyCom(%struct.binding.17.46.75.1786.1815.1960*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local void @subst_ExtractUnifierCom(%struct.binding.17.46.75.1786.1815.1960*, %struct.subst.22.51.80.1791.1820.1965**) local_unnamed_addr #0

declare dso_local %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @clause_CreateBody(i32) local_unnamed_addr #0

declare dso_local %struct.LITERAL_HELP.20.49.78.1789.1818.1963* @clause_LiteralCreate(%struct.term.16.45.74.1785.1814.1959*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local %struct.term.16.45.74.1785.1814.1959* @term_Copy(%struct.term.16.45.74.1785.1814.1959*) #0

declare dso_local void @subst_Delete(%struct.subst.22.51.80.1791.1820.1965*) local_unnamed_addr #0

; Function Attrs: argmemonly nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, ptr nocapture) #1

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_EqualityFactoring(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr, ptr ) local_unnamed_addr #0

declare dso_local fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_ApplyEqualityFactoring(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, i32, i32, %struct.subst.22.51.80.1791.1820.1965*, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenSuperpositionRight(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @clause_Copy(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenLitSPRight(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, ptr, ptr ) unnamed_addr #0

declare dso_local void @clause_Delete(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_MergingParamodulation(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, ptr, ptr ) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_LitMParamod(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, ptr, ptr ) unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_MParamodLitToGiven(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GeneralResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @st_GetUnifier(%struct.binding.17.46.75.1786.1815.1960*, %struct.st.23.52.81.1792.1821.1966*, %struct.binding.17.46.75.1786.1815.1960*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @sharing_NAtomDataList(%struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local void @clause_RenameVarsBiggerThan(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32) local_unnamed_addr #0

declare dso_local i32 @unify_UnifyNoOC(%struct.binding.17.46.75.1786.1815.1960*, %struct.term.16.45.74.1785.1814.1959*, %struct.binding.17.46.75.1786.1815.1960*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local i32 @fflush(%struct.__sFILE.5.34.63.1774.1803.1948*) local_unnamed_addr #0

declare dso_local i32 @fprintf(%struct.__sFILE.5.34.63.1774.1803.1948*, ptr, ...) local_unnamed_addr #0

declare dso_local void @misc_ErrorReport(ptr, ...) local_unnamed_addr #0

declare dso_local fastcc void @misc_DumpCore() unnamed_addr #0

declare dso_local void @subst_ExtractUnifier(%struct.binding.17.46.75.1786.1815.1960*, %struct.subst.22.51.80.1791.1820.1965**, %struct.binding.17.46.75.1786.1815.1960*, %struct.subst.22.51.80.1791.1820.1965**) local_unnamed_addr #0

declare dso_local fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_ApplyGenRes(%struct.LITERAL_HELP.20.49.78.1789.1818.1963*, %struct.LITERAL_HELP.20.49.78.1789.1818.1963*, %struct.subst.22.51.80.1791.1820.1965*, %struct.subst.22.51.80.1791.1820.1965*, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_UnitResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_BoundedDepthUnitResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local i32 @clause_ComputeTermDepth(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local i32 @misc_Max(i32, i32) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GeneralFactoring(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_ApplyGeneralFactoring(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, %struct.subst.22.51.80.1791.1820.1965*, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenSuperpositionLeft(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenLitSPLeft(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_ApplyDefinition(%struct.PROOFSEARCH_HELP.27.56.85.1796.1825.1970*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @def_ApplyDefToClauseOnce(%struct.DEF_HELP.28.57.86.1797.1826.1971*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GeneralHyperResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_DerivableClauses(%struct.PROOFSEARCH_HELP.27.56.85.1796.1825.1970*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local i32 @clause_HasTermSortConstraintLits(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_ForwardSortResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.st.23.52.81.1792.1821.1966*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_ForwardEmptySort(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.st.23.52.81.1792.1821.1966*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_BackwardEmptySort(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.st.23.52.81.1792.1821.1966*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_BackwardSortResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.st.23.52.81.1792.1821.1966*, %struct.SORTTHEORY_HELP.26.55.84.1795.1824.1969*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local void @misc_UserErrorReport(ptr, ...) local_unnamed_addr #0

declare dso_local fastcc void @misc_Error() unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_URResolution(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, ptr, ptr ) local_unnamed_addr #0

declare dso_local i32 @ord_LiteralCompare(%struct.term.16.45.74.1785.1814.1959*, i32, %struct.term.16.45.74.1785.1814.1959*, i32, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local void @term_Delete(%struct.term.16.45.74.1785.1814.1959*) #0

declare dso_local void @clause_OrientEqualities(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr, ptr ) local_unnamed_addr #0

declare dso_local void @clause_Normalize(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local void @clause_SetMaxLitFlags(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr, ptr ) local_unnamed_addr #0

declare dso_local void @clause_UpdateMaxVar(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local i32 @clause_ComputeWeight(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, ptr ) local_unnamed_addr #0

declare dso_local ptr @memory_Malloc(i32) local_unnamed_addr #0

declare dso_local void @free(ptr ) local_unnamed_addr #0

declare dso_local i32 @ord_Compare(%struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.term.16.45.74.1785.1814.1959* @term_Create(i32, %struct.LIST_HELP.14.43.72.1783.1812.1957*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @sharing_GetDataList(%struct.term.16.45.74.1785.1814.1959*, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*) local_unnamed_addr #0

declare dso_local fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_ApplyGenSuperposition(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, %struct.subst.22.51.80.1791.1820.1965*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, %struct.subst.22.51.80.1791.1820.1965*, %struct.term.16.45.74.1785.1814.1959*, i32, i32, i32, ptr, ptr ) unnamed_addr #0

declare dso_local i32 @term_Equal(%struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @list_CopyWithElement(%struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr (ptr )*) local_unnamed_addr #0

declare dso_local void @list_DeleteWithElement(%struct.LIST_HELP.14.43.72.1783.1812.1957*, void (ptr )*) local_unnamed_addr #0

declare dso_local fastcc %struct.term.16.45.74.1785.1814.1959* @inf_AllTermsSideRplacs(%struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.subst.22.51.80.1791.1820.1965*, i32) unnamed_addr #0

declare dso_local fastcc void @clause_SetDataFromParents(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, ptr, ptr ) unnamed_addr #0

define internal fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenSPRightEqToGiven(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964* %0, i32 %1, i32 %2, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967* %3, i32 %4, i32 %5, i32 %6, ptr %7, ptr %8) unnamed_addr #0 {
  %10 = alloca %struct.subst.22.51.80.1791.1820.1965*, align 8
  %11 = alloca %struct.subst.22.51.80.1791.1820.1965*, align 8
  %12 = load %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959** undef, align 8
  br i1 undef, label %13, label %19

13:                                               ; preds = %9
  %14 = getelementptr %struct.term.16.45.74.1785.1814.1959, %struct.term.16.45.74.1785.1814.1959* %12, i64 0, i32 2
  %15 = load %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957** %14, align 8
  %16 = getelementptr %struct.LIST_HELP.14.43.72.1783.1812.1957, %struct.LIST_HELP.14.43.72.1783.1812.1957* %15, i64 0, i32 1
  %17 = bitcast ptr %16 to %struct.term.16.45.74.1785.1814.1959**
  %18 = load %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959** %17, align 8
  br label %19

19:                                               ; preds = %13, %9
  %20 = phi %struct.term.16.45.74.1785.1814.1959* [ %18, %13 ], [ %12, %9 ]
  br i1 undef, label %21, label %22

21:                                               ; preds = %19
  br label %22

22:                                               ; preds = %21, %19
  %23 = load %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957** undef, align 8
  tail call void @sharing_PushListOnStack(%struct.LIST_HELP.14.43.72.1783.1812.1957* %23) #2
  br i1 undef, label %116, label %24

24:                                               ; preds = %22
  %25 = icmp ne i32 %5, 0
  %26 = icmp eq i32 %6, 0
  br label %27

27:                                               ; preds = %114, %24
  br i1 undef, label %28, label %114

28:                                               ; preds = %27
  br i1 undef, label %114, label %29

29:                                               ; preds = %113, %28
  br i1 undef, label %113, label %30

30:                                               ; preds = %111, %29
  br i1 undef, label %31, label %111

31:                                               ; preds = %30
  br i1 undef, label %111, label %32

32:                                               ; preds = %31
  br label %33

33:                                               ; preds = %109, %32
  %34 = load %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964** undef, align 8
  br label %35

35:                                               ; preds = %123, %33
  br i1 undef, label %36, label %117

36:                                               ; preds = %123, %122, %121, %120, %119, %118, %117, %35
  br i1 undef, label %37, label %109

37:                                               ; preds = %36
  br i1 %25, label %38, label %39

38:                                               ; preds = %37
  br i1 undef, label %109, label %39

39:                                               ; preds = %38, %37
  br i1 undef, label %43, label %40

40:                                               ; preds = %39
  br i1 undef, label %43, label %41

41:                                               ; preds = %40
  %42 = icmp eq i32 undef, 0
  br i1 %42, label %43, label %109

43:                                               ; preds = %41, %40, %39
  br i1 undef, label %109, label %44

44:                                               ; preds = %43
  br i1 undef, label %109, label %45

45:                                               ; preds = %44
  br i1 %26, label %47, label %46

46:                                               ; preds = %45
  br i1 undef, label %47, label %109

47:                                               ; preds = %46, %45
  br i1 undef, label %109, label %48

48:                                               ; preds = %47
  call void @clause_RenameVarsBiggerThan(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964* nonnull %0, i32 undef) #2
  call void @subst_ExtractUnifier(%struct.binding.17.46.75.1786.1815.1960* undef, %struct.subst.22.51.80.1791.1820.1965** nonnull %10, %struct.binding.17.46.75.1786.1815.1960* undef, %struct.subst.22.51.80.1791.1820.1965** nonnull %11) #2
  %49 = load %struct.binding.17.46.75.1786.1815.1960*, %struct.binding.17.46.75.1786.1815.1960** @cont_LASTBINDING, align 8
  br i1 false, label %51, label %50

50:                                               ; preds = %130, %48
  store %struct.binding.17.46.75.1786.1815.1960* null, %struct.binding.17.46.75.1786.1815.1960** @cont_LASTBINDING, align 8
  br i1 undef, label %51, label %124

51:                                               ; preds = %130, %129, %128, %127, %126, %125, %124, %50, %48
  store i32 1, ptr @cont_STACKPOINTER, align 4
  br i1 %25, label %52, label %82

52:                                               ; preds = %51
  %53 = load %struct.subst.22.51.80.1791.1820.1965*, %struct.subst.22.51.80.1791.1820.1965** %11, align 8
  br i1 undef, label %54, label %68

54:                                               ; preds = %52
  br i1 undef, label %108, label %55

55:                                               ; preds = %54
  br i1 undef, label %56, label %108

56:                                               ; preds = %55
  br i1 undef, label %68, label %57

57:                                               ; preds = %56
  %58 = call %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965* nonnull undef, %struct.term.16.45.74.1785.1814.1959* undef) #2
  br i1 undef, label %67, label %59

59:                                               ; preds = %57
  br label %60

60:                                               ; preds = %135, %59
  br i1 undef, label %66, label %61

61:                                               ; preds = %60
  br i1 false, label %66, label %62

62:                                               ; preds = %61
  %63 = call %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965* nonnull undef, %struct.term.16.45.74.1785.1814.1959* undef) #2
  br i1 undef, label %65, label %64

64:                                               ; preds = %133, %62
  call void @term_Delete(%struct.term.16.45.74.1785.1814.1959* %58) #2
  br label %108

65:                                               ; preds = %62
  br label %66

66:                                               ; preds = %65, %61, %60
  br i1 undef, label %67, label %131

67:                                               ; preds = %135, %66, %57
  call void @term_Delete(%struct.term.16.45.74.1785.1814.1959* %58) #2
  br label %68

68:                                               ; preds = %67, %56, %52
  br i1 undef, label %69, label %82

69:                                               ; preds = %68
  br i1 undef, label %108, label %70

70:                                               ; preds = %69
  br i1 undef, label %71, label %108

71:                                               ; preds = %70
  br i1 undef, label %82, label %72

72:                                               ; preds = %71
  %73 = call %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965* nonnull %53, %struct.term.16.45.74.1785.1814.1959* undef) #2
  br i1 undef, label %81, label %74

74:                                               ; preds = %72
  br label %75

75:                                               ; preds = %140, %74
  br i1 undef, label %80, label %76

76:                                               ; preds = %75
  br i1 undef, label %80, label %77

77:                                               ; preds = %76
  br i1 undef, label %79, label %78

78:                                               ; preds = %138, %77
  br label %108

79:                                               ; preds = %77
  br label %80

80:                                               ; preds = %79, %76, %75
  br i1 undef, label %81, label %136

81:                                               ; preds = %140, %80, %72
  br label %82

82:                                               ; preds = %81, %71, %68, %51
  br i1 undef, label %88, label %83

83:                                               ; preds = %82
  br i1 undef, label %84, label %88

84:                                               ; preds = %83
  br i1 undef, label %85, label %86

85:                                               ; preds = %84
  br label %86

86:                                               ; preds = %85, %84
  %87 = call i32 @ord_Compare(%struct.term.16.45.74.1785.1814.1959* undef, %struct.term.16.45.74.1785.1814.1959* undef, ptr %7, ptr %8) #2
  br label %88

88:                                               ; preds = %86, %83, %82
  br i1 undef, label %89, label %96

89:                                               ; preds = %88
  br i1 undef, label %90, label %96

90:                                               ; preds = %89
  %91 = load %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959** undef, align 8
  %92 = call %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965* undef, %struct.term.16.45.74.1785.1814.1959* undef) #2
  %93 = load %struct.subst.22.51.80.1791.1820.1965*, %struct.subst.22.51.80.1791.1820.1965** %10, align 8
  %94 = call %struct.term.16.45.74.1785.1814.1959* @term_Copy(%struct.term.16.45.74.1785.1814.1959* %91) #2
  %95 = call %struct.term.16.45.74.1785.1814.1959* @subst_Apply(%struct.subst.22.51.80.1791.1820.1965* %93, %struct.term.16.45.74.1785.1814.1959* %94) #2
  br label %96

96:                                               ; preds = %90, %89, %88
  br i1 undef, label %97, label %104

97:                                               ; preds = %96
  br i1 undef, label %98, label %101

98:                                               ; preds = %97
  br i1 undef, label %99, label %100

99:                                               ; preds = %98
  br label %100

100:                                              ; preds = %99, %98
  br label %101

101:                                              ; preds = %100, %97
  %102 = call fastcc %struct.term.16.45.74.1785.1814.1959* @inf_AllTermsSideRplacs(%struct.term.16.45.74.1785.1814.1959* %20, %struct.term.16.45.74.1785.1814.1959* undef, %struct.term.16.45.74.1785.1814.1959* undef, %struct.subst.22.51.80.1791.1820.1965* undef, i32 undef) #2
  %103 = call fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_ApplyGenSuperposition(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964* %34, i32 undef, %struct.subst.22.51.80.1791.1820.1965* undef, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* %0, i32 %1, %struct.subst.22.51.80.1791.1820.1965* undef, %struct.term.16.45.74.1785.1814.1959* %102, i32 1, i32 %4, i32 %5, ptr %7, ptr %8)
  br label %104

104:                                              ; preds = %101, %96
  br i1 undef, label %106, label %105

105:                                              ; preds = %104
  br label %106

106:                                              ; preds = %105, %104
  br i1 undef, label %108, label %107

107:                                              ; preds = %106
  br label %108

108:                                              ; preds = %107, %106, %78, %70, %69, %64, %55, %54
  br label %109

109:                                              ; preds = %108, %47, %46, %44, %43, %41, %38, %36
  %110 = icmp eq %struct.LIST_HELP.14.43.72.1783.1812.1957* undef, null
  br i1 %110, label %111, label %33

111:                                              ; preds = %109, %31, %30
  %112 = icmp eq %struct.LIST_HELP.14.43.72.1783.1812.1957* undef, null
  br i1 %112, label %113, label %30

113:                                              ; preds = %111, %29
  br i1 undef, label %114, label %29

114:                                              ; preds = %113, %28, %27
  %115 = icmp eq i32 undef, undef
  br i1 %115, label %116, label %27

116:                                              ; preds = %114, %22
  ret %struct.LIST_HELP.14.43.72.1783.1812.1957* undef

117:                                              ; preds = %35
  br i1 undef, label %36, label %118

118:                                              ; preds = %117
  br i1 undef, label %36, label %119

119:                                              ; preds = %118
  br i1 undef, label %36, label %120

120:                                              ; preds = %119
  br i1 undef, label %36, label %121

121:                                              ; preds = %120
  br i1 undef, label %36, label %122

122:                                              ; preds = %121
  br i1 undef, label %36, label %123

123:                                              ; preds = %122
  br i1 undef, label %36, label %35

124:                                              ; preds = %50
  br i1 undef, label %51, label %125

125:                                              ; preds = %124
  br i1 undef, label %51, label %126

126:                                              ; preds = %125
  br i1 undef, label %51, label %127

127:                                              ; preds = %126
  br i1 undef, label %51, label %128

128:                                              ; preds = %127
  br i1 undef, label %51, label %129

129:                                              ; preds = %128
  br i1 undef, label %51, label %130

130:                                              ; preds = %129
  br i1 undef, label %51, label %50

131:                                              ; preds = %66
  br i1 undef, label %135, label %132

132:                                              ; preds = %131
  br i1 undef, label %135, label %133

133:                                              ; preds = %132
  br i1 undef, label %134, label %64

134:                                              ; preds = %133
  br label %135

135:                                              ; preds = %134, %132, %131
  br i1 undef, label %67, label %60

136:                                              ; preds = %80
  br i1 undef, label %140, label %137

137:                                              ; preds = %136
  br i1 undef, label %140, label %138

138:                                              ; preds = %137
  br i1 undef, label %139, label %78

139:                                              ; preds = %138
  br label %140

140:                                              ; preds = %139, %137, %136
  br i1 undef, label %81, label %75
}

declare dso_local void @sharing_PushListOnStack(%struct.LIST_HELP.14.43.72.1783.1812.1957*) local_unnamed_addr #0

declare dso_local i32 @term_HasPointerSubterm(%struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_Lit2MParamod(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.subst.22.51.80.1791.1820.1965*, ptr, ptr ) unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_ApplyMParamod(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, i32, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.subst.22.51.80.1791.1820.1965*, %struct.subst.22.51.80.1791.1820.1965*, ptr, ptr ) unnamed_addr #0

declare dso_local i32 @term_ReplaceSubtermBy(%struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*, %struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local void @sharing_PushReverseOnStack(%struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local void @abort() local_unnamed_addr #0

declare dso_local void @clause_SubstApply(%struct.subst.22.51.80.1791.1820.1965*, %struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local void @clause_DeleteLiteral(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, ptr, ptr ) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_GenSPLeftEqToGiven(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, i32, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, i32, i32, i32, ptr, ptr ) unnamed_addr #0

declare dso_local void @sharing_PushOnStack(%struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local fastcc %struct.LIST_HELP.14.43.72.1783.1812.1957* @inf_HyperResolvents(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.subst.22.51.80.1791.1820.1965*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, %struct.SHARED_INDEX_NODE.24.53.82.1793.1822.1967*, ptr, ptr ) unnamed_addr #0

declare dso_local fastcc %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @inf_BuildHyperResolvent(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*, %struct.subst.22.51.80.1791.1820.1965*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, i32, ptr, ptr ) unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @clause_MoveBestLiteralToFront(%struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.subst.22.51.80.1791.1820.1965*, i32, i32 (%struct.LITERAL_HELP.20.49.78.1789.1818.1963*, i32, %struct.LITERAL_HELP.20.49.78.1789.1818.1963*, i32)*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @list_Copy(%struct.LIST_HELP.14.43.72.1783.1812.1957*) local_unnamed_addr #0

declare dso_local i32 @clause_HyperLiteralIsBetter(%struct.LITERAL_HELP.20.49.78.1789.1818.1963*, i32, %struct.LITERAL_HELP.20.49.78.1789.1818.1963*, i32) #0

declare dso_local i32 @term_MaxVar(%struct.term.16.45.74.1785.1814.1959*) local_unnamed_addr #0

declare dso_local %struct.subst.22.51.80.1791.1820.1965* @subst_Compose(%struct.subst.22.51.80.1791.1820.1965*, %struct.subst.22.51.80.1791.1820.1965*) local_unnamed_addr #0

declare dso_local %struct.subst.22.51.80.1791.1820.1965* @subst_Copy(%struct.subst.22.51.80.1791.1820.1965*) local_unnamed_addr #0

declare dso_local %struct.CLAUSE_HELP.21.50.79.1790.1819.1964* @clause_Create(%struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, %struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr, ptr ) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @list_NReverse(%struct.LIST_HELP.14.43.72.1783.1812.1957*) local_unnamed_addr #0

declare dso_local i32 @clause_SearchMaxVar(%struct.CLAUSE_HELP.21.50.79.1790.1819.1964*) local_unnamed_addr #0

declare dso_local %struct.LIST_HELP.14.43.72.1783.1812.1957* @list_PointerDeleteElement(%struct.LIST_HELP.14.43.72.1783.1812.1957*, ptr ) local_unnamed_addr #0

declare dso_local void @exit(i32) local_unnamed_addr #0

; Function Attrs: nounwind
declare i64 @fwrite(ptr, i64, i64, %struct.__sFILE.5.34.63.1774.1803.1948*) local_unnamed_addr #2

; Function Attrs: argmemonly nofree nosync nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

attributes #0 = { "use-soft-float"="false" }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { nounwind }
attributes #3 = { argmemonly nofree nosync nounwind willreturn writeonly }

!llvm.ident = !{!0}

!0 = !{!"Kalray clang version 12.0.1"}
