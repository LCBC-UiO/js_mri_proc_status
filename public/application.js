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
    const r_data = await fetch(`./cgi/get_data.cgi`);
    r_data_j = await r_data.json();
    const r_process = await fetch(`./cgi/get_process.cgi`);
    r_process_j = await r_process.json();
    e_cols = Object.keys(r_process_j).concat("n_ok");
    let e_table = document.getElementById("tsv");
    var e_body = document.createElement("tbody");
    e_table.appendChild(e_body);
    for(var sub in r_data_j){
        for( var ses in r_data_j[sub]){
            e_tr = document.createElement("tr");
            e_tr.classList = "clickable-row";
            e_tr.id = `${sub}_${ses}`;
            e_tr.sub = `${sub}_${ses}`;
            //e_tr.setAttribute("onclick", `select_row('${sub}_${ses}')`);
            e_body.appendChild(e_tr);
            e_sub = document.createElement("td");
            e_sub.innerHTML = sub;
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
                e_td.classList = `${sub}_${ses} ${e_cols[proc]} text-center m-0`;
                e_p = document.createElement("p");               
                e_p.style.visibility = "hidden";
                e_p.innerHTML = 0; 
                e_p.classList = "p-0 m-0 hide-text";
                e_i = document.createElement("i");
                e_i.classList = "bi";
                e_i.setAttribute("font-size", "2em");
                val = r_data_j[sub][ses][e_cols[proc]];
                opts = Object.values(r_process_j)[proc];
                if(e_cols[proc] == "n_ok"){
                    val = n_ok
                    opts = "numeric"
                }
                if(typeof opts !== "string" ){
                    vars = opts;
                    opts = "custom"
                }
                switch(opts){
                    case "icons": 
                        switch(val) {
                            case "yes":
                                e_i.classList.add("bi-check-circle-fill");
                                e_i.classList.add(val);
                                e_td.classList.add(val);
                                e_p.innerHTML = 1;
                                n_ok = n_ok + 1;
                                break;
                            case "no":
                                e_i.classList.add("bi-x-circle-fill");
                                e_i.classList.add(val);
                                e_td.classList.add(val);
                                e_p.innerHTML = 3;
                                break;
                            case "running":
                                e_i.classList.add("bi-arrow-repeat");
                                e_i.classList.add(val);
                                e_td.classList.add(val); 
                                e_p.innerHTML = 2;
                                break;
                            default:
                                e_i.classList.add("bi-question-circle-fill");
                                e_i.classList.add("unknown");
                                e_td.appendChild(e_i);
                                e_td.classList.add("unknown");     
                        }
                        e_td.appendChild(e_i);
                        break;
                    case "numeric":
                        e_num = document.createElement("p");
                        e_num.classList = "rounded-circle text-black w-75 m-2";
                        if(typeof val == "undefined" || val == "NA"){
                            e_num.classList.add("bg-secondary");
                            val = "NA"
                        }else{
                            e_num.classList.add("bg-light");
                        }
                        e_td.classList.add(val); 
                        e_num.innerHTML = val;
                        e_p.innerHTML = val;
                        n_ok = n_ok + 1;
                        e_td.appendChild(e_num);
                        break;
                    case "custom":
                    case "asis":
                        e_td.classList.add(encodeURI(val));
                        if(typeof val == "undefined"){
                            val = ""
                        }
                        e_a = document.createElement("p");
                        e_a.classList = "text-asis";
                        e_a.width = "150px";
                        e_a.innerHTML = val;
                        if(val.length > 20 ){
                            e_a.classList.add("text-truncate");
                            e_a.classList.add("truncate");
                        }
                        e_td.appendChild(e_a);
                        n_ok = n_ok + 1;
                        break;
                    }
                e_td.appendChild(e_p);     
                e_tr.appendChild(e_td);
            }
        }
    }

    $(document).ready(function () {
        $('#tsv').DataTable({
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
    const r_process = await fetch(`./cgi/get_process.cgi`);
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
    e_proc = document.getElementById("process-preview");
    e_proc.innerHTML = JSON.stringify(r_process_j, null, 2);
};

function update_process(){
    key = document.getElementById("process-key-input").value;
    value = document.getElementById("process-value-input").value;
    if(value == "array"){
        value = document.getElementById("process-custom-input").value.replaceAll(" ", "");
    }
    let getstr = `./cgi/update_process.cgi?=${key.replaceAll(" ", "_")}=${value}`;
    fetch(getstr).then(r =>{
        switch(r.status){
            case 201:
                alert("Process updated.");
                break
            case 204:
                alert(`Some requested process value is not valid. Not updating process.`);
                break
            case 203:
                alert(`Some requested process keys already exist. Not updating process.`);
                break
        }
        location.reload();
     })
     return false;
}

function save_changes(){
    e_selects = document.getElementsByClassName("proc-select");
    var arr = [].slice.call(e_selects);
    sel_vals = arr.map((x, i) => {
        if(x.value == "unknown" || x.value == "undefined"){
            return null
        }
        return(`${x.id}=${encodeURI(x.value)}`)
    }).filter(el => {
        return el !== null;
    })
    subses = document.getElementById("edit-selection");
    subses = subses.innerHTML.split(" ");
    sub=`sub=${subses[0]}`;
    ses=`ses=${subses[1]}`;
    let getstr = `./cgi/update_data.cgi?=${sub}&${ses}&${sel_vals.join('&')}`;
    console.log(getstr)
    fetch(getstr).then(r =>{
        mod_body = document.createElement("div");
        mod_body.classList = `modal-body alert`;
       switch(r.status){
        case 201:
            mod_body.innerHTML = "Successfully updated"
            type = "success"
            break;
        case 202:
            mod_body.innerHTML = "No key-value pair was provided for updating the data."
            type = "danger"
            break;
        case 203:
            mod_body.innerHTML = "Process does not exist"
            type = "danger"
            break;
        case 204:
            mod_body.innerHTML = "Some values do not correspond to values for the given process."
            type = "danger"
            break;
        case 205:
            mod_body.innerHTML = "No sub or ses pair was provided for updating the data."
            type = "danger"
            break;
        default:
            mod_body.innerHTML = "Unknown error occured"
            type = "danger"
            break;
        }
        r.json().then(data => {
            json = create_modal_json(data);
            display_modal( `${subses.join(" ")}`, mod_body, type, json);
        })
    })
}

async function delete_entry(idses){
    fetch(`./cgi/delete_entry.cgi?=${idses}`).then(r =>{
        switch(r.status){
            case 200:
                alert("Entry deleted.");
                break;
            case 201:
                alert(`Unknown error occured.`);
                break;
            case 203:
                alert(`Deletion needs arguments for id, session (optional) and key (optional).`);
                break;
        }
        location.reload();
     })
}

function add_new(){
    sub = document.getElementById("new-sub-input").value;
    ses = document.getElementById("new-ses-input").value;
    select_row(`sub-${sub}_ses-${ses}`);
    return false;
}

// select row action //
async function select_row(text) {
    tsplit = text.split("_");
    n = '';
    mod_body = document.createElement("div");
    mod_body.classList = `modal-body alert`;
    const r_process = await fetch(`./cgi/get_process.cgi`);
    r_process_j = await r_process.json();
    e_row = document.getElementsByClassName(text);
    var arr = [].slice.call(e_row);
    for(col in r_process_j){
        if(arr.length !== 0){
            val = arr.slice(arr.findIndex(j => j.classList.value.split(' ')[1] == col), 
                            arr.findIndex(j => j.classList.value.split(' ')[1] == col)+1)[0]
                            .classList.value.split(' ')[4];
        }
        e_input = document.createElement("div");
        e_input.classList = "input-group mb-3 w-100";
        e_input.setAttribute("data-width", "100%");
        e_input_p = document.createElement("div");
        e_input_p.classList = "input-group-prepend w-50";
        e_input.appendChild(e_input_p);
        e_input_pl = document.createElement("label");
        e_input_pl.classList = "input-group-text v-5rem";
        e_input_pl.setAttribute("for", col);
        e_input_pl.innerHTML = col.replaceAll("_", " ");
        e_input_p.appendChild(e_input_pl);
        switch(r_process_j[col]){
            case "icons":
                e_input_sel = document.createElement("select");
                e_input_sel.classList = "custom-select border-secondary w-50 proc-select";
                e_input_sel.id = col;
                e_input.appendChild(e_input_sel);
                opts = ["unknown", "yes", "no", "running"];
                for(opt in opts){
                    e_input_op = document.createElement("option");
                    e_input_op.value = opts[opt];
                    e_input_op.innerHTML = opts[opt];
                    if(arr.length !== 0 & opts[opt] == val){
                        e_input_op.setAttribute("selected", true)
                    }
                    e_input_sel.appendChild(e_input_op);
                }
                break;
            case "numeric":
            case "asis":
                if(arr.length === 0 || typeof val == "undefined" || val == "undefined" || val == "NA"){
                    val = ""
                }
                e_input_input = document.createElement("input");
                e_input_input.setAttribute("type", "text");
                e_input_input.classList = "form-control proc-select";
                e_input_input.id = col;
                e_input_input.innerHTML = decodeURI(val);
                e_input_input.value = decodeURI(val);
                e_input.appendChild(e_input_input);
                break;
            default:
                e_input_sel = document.createElement("select");
                e_input_sel.classList = "custom-select border-secondary w-50 proc-select";
                e_input_sel.id = col;
                e_input.appendChild(e_input_sel);
                opts = ["unknown"].concat(r_process_j[col]);
                for(opt in opts){
                    e_input_op = document.createElement("option");
                    e_input_op.value = opts[opt];
                    e_input_op.innerHTML = opts[opt];
                    if(arr.length !== 0 & opts[opt] == val){
                        e_input_op.setAttribute("selected", true)
                    }
                    e_input_sel.appendChild(e_input_op);
                }
                break;
        }
        mod_body.appendChild(e_input);
    };
    mod_foot = document.createElement("div");
    mod_foot.classList = "d-flex justify-content-between modal-footer";
    mod_foot_btn_del =  create_mod_btn("Delete entry", `display_modal_delete("${text}")`, "danger"); 
    mod_foot.appendChild(mod_foot_btn_del);
    mod_foot_btn     = create_mod_btn("Save changes", 'save_changes()', "secondary"); 
    mod_foot.appendChild(mod_foot_btn);

    display_modal(`${tsplit.join(' ')}`, mod_body, null, mod_foot)
}


// modals //
function display_modal(title, body=null, type=null, footer=null){
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
    if(body != null ){
        mod_body = document.createElement("div");
        mod_body.classList = `modal-body alert alert-${type}`;
        mod_body.appendChild(body);
        mod_cont.appendChild(mod_body);
    }
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

async function display_modal_new(){
    body = document.createElement("form");
    body.setAttribute("onsubmit", "return add_new()");
    body.classList = "w100";
    ["sub", "ses"].forEach(x => {
        body_id = document.createElement("div");
        body_id.classList = "input-group mb-3";
        body_id_lab = document.createElement("div");
        body_id_lab.classList = "input-group-prepend";
        body_id_lab_span = document.createElement("span");
        body_id_lab_span.classList = "input-group-text";
        body_id_lab_span.id = `new-${x}`;
        body_id_lab_span.innerHTML = `${x}-`;
        body_id_lab.appendChild(body_id_lab_span);
        body_id.appendChild(body_id_lab)
        body_id_input = document.createElement("input");
        body_id_input.classList = "form-control  w-50";
        body_id_input.type = "text";
        body_id_input.setAttribute("aria-describedby", `new-${x}`);
        body_id_input.setAttribute("required", true);
        body_id_input.id = `new-${x}-input`;
        body_id.appendChild(body_id_input);
        body.appendChild(body_id);
    })
    foot = document.createElement("div");
    foot_btn = document.createElement("button");
    foot_btn.classList = "btn btn-secondary";
    foot_btn.innerHTML = "Initiate entry";
    foot_btn.type = "submit";
    foot.appendChild(foot_btn);
    body.appendChild(foot);
    display_modal("Add new entry", body)
}
function create_mod_btn(title, onclick, type="secondary"){
    mod_foot_btn = document.createElement("button");
    mod_foot_btn.setAttribute("type", "button");
    mod_foot_btn.classList = `btn btn-${type}`;
    mod_foot_btn.innerHTML = title;
    mod_foot_btn.setAttribute("onclick", onclick);
    return mod_foot_btn;
}
async function display_modal_delete(idses){
    delentry = idses.split("_").join("&").split("-").join("=");
    const r_data = await fetch(`./cgi/get_data.cgi?=${delentry}`);
    r_data_j = await r_data.json();
    body = create_modal_json(r_data_j, "danger")
    mod_foot = document.createElement("div");
    mod_foot.classList = "d-flex justify-content-between modal-footer";
    mod_foot_btn_del =  create_mod_btn("Confirm delete", `delete_entry("${delentry}")`, "danger"); 
    mod_foot.appendChild(mod_foot_btn_del);
    display_modal(idses.split("_").join(" "), body=body, type="danger", footer=mod_foot)
}

function display_modal_process(){
    body = document.createElement("form");
    body.setAttribute("onsubmit", "return update_process()");
    body.classList = "w100"
    body_text = document.createElement("div");
    body_text.innerHTML = "Here you can add more processing steps to the table. The keys should be in <code>snake_case</code>."
    // key
    body_key_group = document.createElement("div");
    body_key_group.classList = "input-group mb-3";
    body_key = document.createElement("div");
    body_key.classList = "input-group-prepend";
    body_key_span = document.createElement("span");
    body_key_span.classList = "input-group-text";
    body_key_span.id = `process-key`;
    body_key_span.innerHTML = "Key";
    body_key.appendChild(body_key_span);
    body_key_group.appendChild(body_key)
    body_input = document.createElement("input");
    body_input.classList = "form-control  w-50";
    body_input.type = "text";
    body_input.setAttribute("aria-describedby", `process-key`);
    body_input.setAttribute("required", true);
    body_input.id = "process-key-input"
    body_key_group.appendChild(body_input);
    body.appendChild(body_key_group);
    //value
    body_val_group = document.createElement("div");
    body_val_group.classList = "input-group mb-3";
    body_val = document.createElement("div");
    body_val.classList = "input-group-prepend";
    body_val_group.appendChild(body_val)
    body_val_label = document.createElement("label");
    body_val_label.classList = "input-group-text";
    body_val_label.innerHTML = "Value";
    body_val.appendChild(body_val_label);
    body_select = document.createElement("select");
    body_select.setAttribute("for", "process-value-input");
    body_select.classList = "custom-select";
    body_select.id = "process-value-input";
    body_select.setAttribute("onchange", "init_custom_input()")
    body_val_group.appendChild(body_select);
    body.appendChild(body_val_group);
    ["icons", "numeric", "asis", "array"].forEach(x => {
        opt = document.createElement("option");
        opt.innerHTML = x;
        opt.value = x;
        body_select.appendChild(opt);
    })
    body_custom = document.createElement("div");
    body_custom.id = "custom-array";
    body.appendChild(body_custom);
    body_help = document.createElement("small");
    body_help.classList = "text-muted mb-2";
    body_help.id = "process-select-help";
    body.appendChild(body_help);
    foot = document.createElement("div");
    foot_btn = document.createElement("button");
    foot_btn.classList = "btn btn-secondary";
    foot_btn.innerHTML = "Add step";
    foot_btn.type = "submit";
    foot.appendChild(foot_btn);
    body.appendChild(foot);
    display_modal("Adding process", body);
    init_custom_input();
}

function init_custom_input(){
    choice = document.getElementById("process-value-input").value;
    body_custom = document.getElementById("custom-array");
    body_custom.innerHTML = "";
    if(choice == "array"){
        body_custom.classList = "input-group mb-3";
        body_custom_pre = document.createElement("div");
        body_custom_pre.classList = "input-group-prepend";
        body_custom_in = document.createElement("span");
        body_custom_in.classList = "input-group-text";
        body_custom_in.id = `process-custom`;
        body_custom_in.innerHTML = "Custom array (comma sep)";
        body_custom_pre.appendChild(body_custom_in);
        body_custom.appendChild(body_custom_pre)
        body_custom_input = document.createElement("input");
        body_custom_input.classList = "form-control  w-50";
        body_custom_input.type = "text";
        body_custom_input.setAttribute("aria-describedby", `process-custom`);
        body_custom_input.setAttribute("required", true);
        body_custom_input.id = "process-custom-input"
        body_custom.appendChild(body_custom_input);
    }
    help = document.getElementById("process-select-help");
    help.innerHTML = "";
    switch(choice){
        case "array":
            help.innerHTML = "Create a custom array of values by entering a comma separated list."
            break;
        case "asis":
            help.innerHTML = "Data in these keys will be displayed as is. Mostly used for freetext content."
            break;
        case "numeric":
            help.innerHTML = "Data will be validated as a number."
            break;
        case "icons":
            help.innerHTML = "The values 'yes', 'no', and 'running' will be displayed as icons in the table."
            break;
    }
}

function create_modal_json(data=null, alert="secondary"){
    var ed_div = document.createElement("div");
    ed_div.classList = `alert alert-${alert}`;
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

$('body :not(script)').contents().filter(function() {
    return this.nodeType === 3;
  }).replaceWith(function() {
      return this.nodeValue.replace(/WEBSITEURL/g, window.location.origin);
  });


$("#tsv").on("click", "td", function(event){
    console.log($(event.target))
    if(!$(event.target).hasClass('truncate')) {
        select_row(event.target.parentElement.id);
    }else if($(event.target).hasClass('text-truncate')){
        $(event.target).removeClass('text-truncate')
    }else if(!$(event.target).hasClass('text-truncate')){
        $(event.target).addClass('text-truncate')
    }
});

// Start the whole thing!
get_process();
get_data();
get_moddate();


