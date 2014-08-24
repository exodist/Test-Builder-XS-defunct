#define PERL_NO_GET_CONTEXT
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

typedef struct trace_vars   trace_vars;
typedef struct trace_state  trace_state;
typedef struct trace_details trace_details;

// Initializers
void init_trace_vars(trace_vars *vars);
void init_trace_state(trace_state *ts);

// Detail calculators
void V_tb_trace_details(trace_details* td);
void V_tb_anoint_details(trace_details *td);
void V_tb_tool_details(trace_details *td);
void V_tb_trans_details(trace_details *td);
void V_tb_level_details(trace_details *td);
void V_tb_package_details(trace_details *td);

// Misc Utils
SV* S_tb_cx_name(const PERL_CONTEXT* cx);
I32 I_tb_seek_level(); // $Test::Builder::Level - $Test::Builder::BLevel
void V_tb_find_report(trace_vars* vars, trace_state* ts);

// The Meat
SV* S_tb_trace();

// {{{ Structures

struct trace_vars {
    AV* full;
    AV* anointed;
    AV* tools;
    AV* transitions;

    SV* level;
    SV* instance;
    SV* todo_message;
    SV* todo_package;
    SV* encoding;
    SV* report;
};

struct trace_state {
    I32 index;
    I32 tools;
    I32 seek_level;
    I32 notb_level;

    HV* bldr_pkgs;
    HV* provided;

    SV* anoint_report;

    int hit_nest;
    int transition;
};

struct trace_details {
    HV* details;

    SV* row;
    SV* package;
    SV* subname;

    trace_vars*  vars;
    trace_state* ts;

    const PERL_CONTEXT* cx;

    I32 anointed;
    I32 builder_package;
    I32 tool;
};

// }}}

// {{{ Initializers

void init_trace_vars(trace_vars *vars) {
    // Is memset, or something equivilent available?
    vars->level        = NULL;
    vars->instance     = NULL;
    vars->todo_message = NULL;
    vars->todo_package = NULL;
    vars->encoding     = NULL;
    vars->report       = NULL;

    vars->full         = newAV();
    vars->anointed     = newAV();
    vars->tools        = newAV();
    vars->transitions  = newAV();
}

void init_trace_state(trace_state *ts) {
    ts->index      = cxstack_ix;
    ts->tools      = 0;
    ts->seek_level = I_tb_seek_level();
    ts->notb_level = 0;

    ts->bldr_pkgs = get_hv("Test::Builder::Trace::Frame::BUILDER_PACKAGES", 0);
    ts->provided = get_hv("Test::Builder::Provider::PROVIDED", 0);

    ts->anoint_report = NULL;

    ts->hit_nest   = 0;
    ts->transition = 1; // Calling a trace is obviously part of TB
}

// }}}

// {{{ Detail calculators

void V_tb_trace_details(trace_details* td) {
    // If it is a builder package, we do not need to find more details
    V_tb_package_details(td);
    if (td->builder_package) return;

    V_tb_trans_details (td);
    V_tb_anoint_details(td);
    V_tb_tool_details  (td);
    V_tb_level_details (td);

    if (!td->ts->anoint_report && td->anointed && !td->tool) {
        td->ts->anoint_report = td->row;
    }
}

void V_tb_anoint_details(trace_details *td) {
    HV*  stash  = CopSTASH(td->cx->blk_oldcop);
    SV** tester = hv_fetch(stash, "TB_TESTER_META", 14, 0);
    if (!tester) return;

    CV* testerv = GvCV(*tester);
    if (!testerv) return;

    td->anointed = 1;

    av_push(td->vars->anointed, td->row);
    SvREFCNT_inc(td->row);

    if (!td->details) td->details = newHV();
    hv_store(td->details, "anointed", 8, newSVnv(1), 0);

    HV* testerhv = GvHV(*tester);
    SV** enc = hv_fetch(testerhv, "encoding", 8, 0);
    if (enc && SvOK(*enc)) {
        SV* copy = newSVsv(*enc);
        hv_store(td->details, "encoding", 8, copy, 0);
        if (!td->vars->encoding) {
            SvREFCNT_inc(copy);
            td->vars->encoding = copy;
        }
    }

    SV** instance_glob = hv_fetch(stash, "TB_INSTANCE", 11, 0);
    SV*  instance_ref  = instance_glob ? GvSV(*instance_glob) : NULL;
    if (instance_ref) {
        hv_store(td->details, "instance", 8, instance_ref, 0);
        SvREFCNT_inc(instance_ref);

        if (!td->vars->instance) {
            td->vars->instance = instance_ref;
            SvREFCNT_inc(td->vars->instance);
        }
    }

    SV** todo = hv_fetch(stash, "TODO", 4, 0);
    SV*  val  = todo ? GvSV(*todo) : NULL;
    if (val) {
        hv_store(td->details, "has_todo", 8, newSVnv(1), 0);

        if (!td->vars->todo_package) {
            td->vars->todo_package = td->package;
            SvREFCNT_inc(td->package);
        }

        if (SvOK(val)) {
            SV* copy = newSVsv(val);
            hv_store(td->details, "todo", 4, copy, 0);
            if (!td->vars->todo_message) {
                td->vars->todo_message = copy;
                SvREFCNT_inc(copy);

                if (td->vars->todo_package) SvREFCNT_dec(td->vars->todo_package);
                td->vars->todo_package = td->package;
                SvREFCNT_inc(td->package);
            }
        }
    }
}

void V_tb_tool_details(trace_details *td) {
    HE* entry = hv_fetch_ent(td->ts->provided, td->subname, 0, 0);
    if (!entry) return;

    td->ts->tools++;
    td->tool = 1;

    if (!td->details) td->details = newHV();

    SV* val = HeVAL(entry);
    hv_store(td->details, "provider", 8, HeVAL(entry), 0);
    SvREFCNT_inc(val);

    av_push(td->vars->tools, td->row);
    SvREFCNT_inc(td->row);
}

void V_tb_trans_details(trace_details *td) {
    if (!td->ts->transition) {
        td->ts->notb_level++;
        return;
    }

    td->ts->transition = 0;
    td->ts->notb_level = 1;

    if(!td->details) td->details = newHV();
    hv_store(td->details, "transition", 10, newSVnv(1), 0);

    av_push(td->vars->transitions, td->row);
    SvREFCNT_inc(td->row);
}

void V_tb_level_details(trace_details *td) {
    if (!td->ts->seek_level)
        return;

    if (td->ts->notb_level != td->ts->seek_level)
        return;

    td->vars->level = td->row;
    SvREFCNT_inc(td->row);

    if (!td->details) td->details = newHV();
    hv_store(td->details, "level", 5, newSVnv(1), 0);

    // This is copied from the PP implementation, but I can no longer remember
    // what it fixed, disabling for now unless a TB test failed without it.
    //if (!td->ts->tools)   return;
    //if (td->vars->report) return;
    //if (td->anointed)     return;

    //hv_store(td->details, "report", 6, newSVnv(1), 0);

    //td->vars->report = td->row;
    //SvREFCNT_inc(td->row);
}

void V_tb_package_details(trace_details *td) {
    if (!hv_exists_ent(td->ts->bldr_pkgs, td->package, 0))
        return;

    td->builder_package++;

    if(!td->details) td->details = newHV();
    hv_store(td->details, "builder", 7, newSVnv(1), 0);
    td->ts->transition = 1;
    td->ts->notb_level = 0;
}

// }}}

// {{{ Misc Utils

// $Test::Builder::Level - $Test::Builder::BLevel
I32 I_tb_seek_level() {
    HV* stash = gv_stashpv("Test::Builder", 0);
    if (!stash) return 0;

    SV** Lev = hv_fetch(stash, "Level", 5, 0);
    if (!Lev) return 0;

    SV** BLev = hv_fetch(stash, "BLevel", 6, 0);
    if (!BLev) return 0;

    return SvIV(GvSV(*Lev)) - SvIV(GvSV(*BLev));
}

SV* S_tb_cx_name(const PERL_CONTEXT* cx) {
    if (CxTYPE(cx) == CXt_SUB || CxTYPE(cx) == CXt_FORMAT) {
        GV * const cvgv = CvGV(cx->blk_sub.cv);
        if (isGV(cvgv)) {
            SV * const name = newSV(0);
            gv_efullname3(name, cvgv, NULL);
            return name;
        }
        else {
            return newSVpvn("(unknown)", 9);
        }
    }

    if (CxTYPE(cx) == CXt_EVAL) {
        return newSVpvn("(eval)", 6);
    }

    return NULL;
}

void V_tb_find_report(trace_vars* vars, trace_state *ts) {
    if (vars->report) return;

    SV* level    = vars->level;
    SV* anointed = ts->anoint_report;

    SV** toolp = av_fetch(vars->tools, av_tindex(vars->tools), 0); // [-1]
    SV** tranp = av_fetch(vars->transitions, av_tindex(vars->transitions), 0); //[-1]

    if (toolp && level) {
        // index 4 is stack index
        SV **tool_depth = av_fetch((AV*)SvRV(*toolp), 4, 0);
        SV **levl_depth = av_fetch((AV*)SvRV(level),  4, 0);
        I32 t = SvIV(*tool_depth);
        I32 l = SvIV(*levl_depth);

        // We want the one closest to the bottom (lowest index)
        if (l < t) {
            vars->report = level;
        }
        else {
            vars->report = *toolp;
        }
    }
    else if (level) {
        vars->report = level;
    }
    else if (toolp) {
        vars->report = *toolp;
    }
    else if (anointed) {
        vars->report = anointed;
    }
    else if (tranp) {
        vars->report = *tranp;
    }

    if (vars->report) {
        SvREFCNT_inc(vars->report);

        // index 5 is details
        SV** detailsp = av_fetch((AV*)(SvRV(vars->report)), 5, 0);
        HV*  details  = (HV*)(SvRV(*detailsp));
        hv_store(details, "report", 6, newSVnv(1), 0);
    }
}

// }}}

SV* S_tb_trace() {
    HV* rowstash  = gv_stashpv("Test::Builder::XS::Frame", GV_ADD);
    SV* nest_name = newSVpvn("Test::Builder::Trace::nest", 26);

    trace_vars vars;
    init_trace_vars(&vars);

    trace_state ts;
    init_trace_state(&ts);

    for (; ts.index > 0; ts.index--) {
        const PERL_CONTEXT* cx = cxstack + ts.index;

        SV* subname = S_tb_cx_name(cx);
        if (!subname) continue; // Not a meaningful stack frame

        AV* row  = newAV();
        SV* package = newSVpv(CopSTASHPV(cx->blk_oldcop), 0);

        av_push(row, package);
        av_push(row, newSVpv(OutCopFILE(cxstack[ts.index].blk_oldcop), 0));
        av_push(row, newSViv(CopLINE(cxstack[ts.index].blk_oldcop)));
        av_push(row, subname);
        av_push(row, newSVnv(ts.index));

        // Push the row now
        SV* rref = sv_bless(newRV_noinc((SV*)row), rowstash);
        av_push(vars.full, rref);

        // Do not get details beyond the nest.
        if (ts.hit_nest) continue;
        if (!sv_cmp(nest_name, subname)) {
            ts.hit_nest = 1;
            continue;
        }

        trace_details td = { NULL, rref, package, subname, &vars, &ts, cx, 0, 0, 0 };
        V_tb_trace_details(&td);
        if (td.details) av_push(row, newRV_noinc((SV*)(td.details)));
    }

    HV* retstash = gv_stashpv("Test::Builder::XS::Trace", 0);
    HV* ret = newHV();

    V_tb_find_report(&vars, &ts);

    if(vars.level)        hv_store(ret, "level",         5, vars.level,        0);
    if(vars.report)       hv_store(ret, "report",        6, vars.report,       0);
    if(vars.instance)     hv_store(ret, "instance",      8, vars.instance,     0);
    if(vars.encoding)     hv_store(ret, "encoding",      8, vars.encoding,     0);
    if(vars.todo_message) hv_store(ret, "todo_message", 12, vars.todo_message, 0);
    if(vars.todo_package) hv_store(ret, "todo_package", 12, vars.todo_package, 0);

    hv_store(ret, "full",        4,  newRV_noinc((SV*)(vars.full)),        0);
    hv_store(ret, "anointed",    8,  newRV_noinc((SV*)(vars.anointed)),    0);
    hv_store(ret, "transitions", 11, newRV_noinc((SV*)(vars.transitions)), 0);
    hv_store(ret, "tools",       5,  newRV_noinc((SV*)(vars.tools)),       0);

    return sv_bless(newRV_noinc((SV*)ret), retstash);
}

#define tb_trace() S_tb_trace()

MODULE = Test::Builder::XS  PACKAGE = Test::Builder::XS

SV*
tb_trace()

