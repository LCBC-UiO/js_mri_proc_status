////////////////////////////////////
// GETTING DATA FROM SYSTEM FILES //

async function get_moddate(){
    let getstr = `./cgi/get_lastmod.cgi`;
    fetch(getstr).then(r =>{
       return r.text().then(function(text) {
        e_div = document.getElementById("lastmod");
        e_div.innerHTML = `Last modified on ${text}`;
      });
    });
}

async function get_data() {
    const r_data = await fetch("./json/data.json");
    r_data_j = await r_data.json();

    const r_process = await fetch("./json/process.json");
    r_process_j = await r_process.json();
    e_cols = Object.keys(r_process_j).concat("n_ok");
    let e_table = document.getElementById("tsv");
    var e_body = document.createElement("tbody");
    e_table.appendChild(e_body);
    for(var id in r_data_j){
        for( var ses in r_data_j[id]){
            e_tr = document.createElement("tr");
            e_tr.setAttribute("onclick", 'select_row()');
            e_tr.id = `${id}_${ses}`;
            e_tr.setAttribute("onclick", `select_row('${id}_${ses}')`);
            e_body.appendChild(e_tr);
            e_sub = document.createElement("td");
            e_sub.innerHTML = id;
            e_sub.setAttribute("width", "100px");
            e_sub.classList = "sticky-left-col1";
            e_tr.appendChild(e_sub);
            e_ses = document.createElement("td");
            e_ses.innerHTML = ses;
            e_ses.classList = "sticky-left-col2";
            e_ses.setAttribute("width", "100px");
            e_tr.appendChild(e_ses);
            n_ok = 1;
            for(var proc in e_cols){
                e_td = document.createElement("td");
                e_td.classList = ` ${id}_${ses} ${e_cols[proc]} text-center m-0`;
                e_p = document.createElement("p");               
                e_p.style.visibility = "hidden";
                e_p.innerHTML = 0; 
                e_p.classList = "p-0 m-0 hide-text";
                e_i = document.createElement("i");
                e_i.classList = "bi";
                e_i.setAttribute("font-size", "2em");
                val = r_data_j[id][ses][e_cols[proc]];
                opts = Object.values(r_process_j)[proc];
                if(e_cols[proc] == "n_ok"){
                    val = n_ok
                    opts = "numeric"
                }
                if(opts == 'numeric'){
                    if(typeof val == "undefined"){ n="NA" }else{ n=val};
                    val = "numeric"
                }else{
                    e_td.appendChild(e_i);
                }
                switch(val) {
                    case "yes":
                        e_i.classList.add("bi-check-circle-fill");
                        e_i.classList.add("ok");
                        e_td.classList.add("ok");
                        e_p.innerHTML = 1;
                        n_ok = n_ok + 1;
                        break;
                    case "no":
                        e_i.classList.add("bi-x-circle-fill");
                        e_i.classList.add("fail");
                        e_td.classList.add("fail");
                        e_p.innerHTML = 3;
                        break;
                    case "running":
                        e_i.classList.add("bi-arrow-repeat");
                        e_i.classList.add("running");
                        e_td.classList.add("running"); 
                        e_p.innerHTML = 2;
                        break;
                    case "numeric":
                        e_num = document.createElement("p");
                        e_num.classList = "rounded-circle text-black w-75 m-2";
                        if(n == "NA"){
                            e_num.classList.add("bg-secondary");
                        }else{
                            e_num.classList.add("bg-light");
                        }
                        e_td.classList.add(n); 
                        e_num.innerHTML = n;
                        e_p.innerHTML = n;
                        n_ok = n_ok + 1;
                        e_td.appendChild(e_num);
                        break;
                    default:
                        e_i.classList.add("bi-question-circle-fill");
                        e_i.classList.add("unknown");
                        e_td.classList.add("unknown");                    
                    }
                e_td.appendChild(e_p);     
                e_tr.appendChild(e_td);
            }
        }
    }

    $(document).ready(function () {
        var table = $('#tsv').DataTable({
            order:[[e_cols.length+1,'asc']],
            lengthMenu: [
                [50, 100, 500, 1000, -1], // values
                [50, 100, 500, '1k', 'All'] // labels
            ],
            buttons: [ 'copy', 'print', 'colvis' ],
            scrollY:        "65vh",
            scrollX:        true,
            fixedColumns:   {left: 2}
        });
    })
};

async function get_process() {
    const r_process = await fetch("./json/process.json");
    r_process_j = await r_process.json();
    let e_table = document.getElementById("tsv");
    var e_head = document.createElement("thead");
    e_head.classList = "thead-dark ";
    var e_thead_tr = document.createElement("tr");
    let e_cols = ['subject_id', 'session'];
    e_cols = e_cols.concat( Object.keys(r_process_j));
    e_cols = e_cols.concat("n_ok");
    for(var i in e_cols){
        var e_thead_tr_th = document.createElement("th");
        e_thead_tr_th.setAttribute("scope", "col");
        if(i == 0){
            e_thead_tr_th.setAttribute("width", "100px");
            e_thead_tr_th.classList.add = "sticky-left-col1";
        }
        if(i == 1){
            e_thead_tr_th.setAttribute("width", "100px");
            e_thead_tr_th.classList.add = "sticky-left-col2";
        }
        e_thead_tr_th.innerHTML = e_cols[i].replaceAll("_", " ");
        e_thead_tr.appendChild(e_thead_tr_th);
    }
    e_head.appendChild(e_thead_tr);
    e_table.appendChild(e_head);
};

// select row action //
async function select_row(text) {
    tsplit = text.split("_");
    n = '';
    mod_body = document.createElement("div");
    mod_body.classList = `modal-body alert`;
    const r_process = await fetch("./json/process.json");
    r_process_j = await r_process.json();
    e_row = document.getElementsByClassName(text);
    var arr = [].slice.call(e_row);
    arr = arr.slice(0, arr.findIndex(j => j.classList.value.split(' ')[1] == "n_ok"));
    arr.forEach((x, i) => {
        col = x.classList.value.split(' ')[1];
        val = x.classList.value.split(' ')[4];
        e_input = document.createElement("div");
        e_input.classList = "input-group mb-3 w-100";
        e_input.setAttribute("data-width", "100%")
        e_input_p = document.createElement("div");
        e_input_p.classList = "input-group-prepend w-50";
        e_input.appendChild(e_input_p);
        e_input_pl = document.createElement("label");
        e_input_pl.classList = "input-group-text v-5rem";
        e_input_pl.setAttribute("for", col)
        e_input_pl.innerHTML = col.replaceAll("_", " ");
        e_input_p.appendChild(e_input_pl)
        if(r_process_j[col] == "options"){
            e_input_sel = document.createElement("select");
            e_input_sel.classList = "custom-select border-secondary w-50 proc-select";
            e_input_sel.id = col;
            e_input.appendChild(e_input_sel);
            opts = ["yes", "no", "running", "unknown"];
            for(opt in opts){
                e_input_op = document.createElement("option");
                e_input_op.value = opts[opt];
                e_input_op.innerHTML = opts[opt];
                if(opts[opt] == val){
                    e_input_op.setAttribute("selected", true)
                }
                e_input_sel.appendChild(e_input_op);
            }
        }else{
            e_input_input = document.createElement("input");
            e_input_input.setAttribute("type", "text");
            e_input_input.classList = "form-control proc-select";
            e_input_input.id = col;
            e_input_input.innerHTML = val;
            e_input_input.value = val;
            e_input.appendChild(e_input_input);
        }
        mod_body.appendChild(e_input);
    })
    mod_foot = document.createElement("div");
    mod_foot.classList.add("modal-footer");
    mod_foot_btn = document.createElement("button");
    mod_foot_btn.setAttribute("type", "button");
    mod_foot_btn.classList = "btn btn-secondary";
    mod_foot_btn.innerHTML = "Save changes";
    mod_foot_btn.setAttribute("onclick", 'save_changes()');
    mod_foot.appendChild(mod_foot_btn);

    display_modal(`${tsplit.join(' ')}`, mod_body, null, mod_foot)
}

// modals //
function display_modal(title, body, type, footer=null){
    mod = document.getElementById("modal");
    mod.innerHTML = "";
    mod_diag = document.createElement("div");
    mod_diag.classList = "modal-dialog";
    mod_diag.setAttribute("role", "document");
    mod.appendChild(mod_diag);
    mod_cont = document.createElement("div");
    mod_cont.classList = "modal-content";
    mod_diag.appendChild(mod_cont);
    mod_head = document.createElement("div");
    mod_head.classList = "modal-header";
    mod_cont.appendChild(mod_head);
    mod_h4 = document.createElement("h4");
    mod_h4.id = "edit-selection";
    mod_h4.innerHTML = title;
    mod_h4.setAttribute("value", title);
    mod_head.appendChild(mod_h4);
    mod_dismiss = document.createElement("button");
    mod_dismiss.classList = "btn close";
    mod_dismiss.setAttribute("aria-label", "Close");
    mod_dismiss.setAttribute("data-bs-dismiss", "modal");
    mod_dismiss_span = document.createElement("span");
    mod_dismiss_span.innerHTML = "&times;"
    mod_dismiss_span.setAttribute("aria-hidden", "true");
    mod_dismiss.appendChild(mod_dismiss_span);
    mod_head.appendChild(mod_dismiss);
    mod_body = document.createElement("div");
    mod_body.classList = `modal-body alert alert-${type}`;
    mod_body.appendChild(body);
    mod_cont.appendChild(mod_body);
    if(footer != null){
        if(typeof footer == "string"){
            mod_foot = document.createElement("div");
            mod_foot_sm = document.createElement("small");
            mod_foot_sm.innerHTML = footer;
            mod_foot_sm.classList = "text-muted text-align-right";
            mod_foot.appendChild(mod_foot_sm);
        }else{
            mod_foot = footer;
        }
        mod_foot.classList.add("modal-footer");
        mod_cont.appendChild(mod_foot);
    }
    $('#modal').modal('show');
}

save_changes = function(){
    e_selects = document.getElementsByClassName("proc-select");
    var arr = [].slice.call(e_selects);
    sel_vals = arr.map((x, i) => {
        if(x.value == "unknown"){
            return null
        }
        return(`${x.id}=${x.value}`)
    }).filter(el => {
        return el !== null;
    })
    idses = document.getElementById("edit-selection");
    idses = idses.innerHTML.split(" ");
    id=`id=${idses[0]}`;
    ses=`ses=${idses[1]}`;
    let getstr = `./cgi/update_data.cgi?=${id}&${ses}&${sel_vals.join('&')}`;
    console.log(getstr)
    fetch(getstr).then(r =>{
       switch(r.status){
        case 201:
                r.json().then(data => {
                    mod_body = document.createElement("div");
                    mod_body.classList = `modal-body alert`;
                    mod_body.innerHTML = "Successfully updated"
                    display_modal( `${idses}`,
                        mod_body, "success", 
                        create_modal_footer(data))
                })
                break;
        }
    })
}


function create_modal_footer(data=null){
    var ed_div = document.createElement("div");
    ed_div.classList = "alert alert-secondary";
    if(data != null){
        e_pre = document.createElement("pre");
        e_pre.classList = "w-100 border border-white border-2";
        e_pre_h4 = document.createElement("h4");
        e_pre_h4.innerHTML = "Entry json";
        e_pre_h4.classList = "my-2 w-100 text-muted";
        e_code = document.createElement("code");
        e_code.classList = "language-json text-muted";
        e_code.innerHTML = JSON.stringify(data, null, 2);
        ed_div.appendChild(e_pre_h4);
        e_pre.appendChild(e_code);
        ed_div.appendChild(e_pre);
    }
    return ed_div;
}

// refresh page when modal is closed
$('#modal').on('hidden.bs.modal', function () {
    location.reload();
})

// Start the whole thing, grab data list!
get_process();
get_data();
get_moddate();

