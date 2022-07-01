////////////////////////////////////
// GETTING DATA FROM SYSTEM FILES //
async function get_data() {
    const r_data = await fetch("./json/data.json");
    r_data_j = await r_data.json();

    const r_process = await fetch("./json/process.json");
    r_process_j = await r_process.json();
    e_cols = r_process_j.columns;

    let e_table = document.getElementById("tsv");
    var e_body = document.createElement("tbody");
    e_table.appendChild(e_body);
    for(var id in r_data_j){
        for( var ses in r_data_j[id]){
            e_tr = document.createElement("tr");
            e_body.appendChild(e_tr);
            e_sub = document.createElement("td");
            e_sub.innerHTML = id;
            e_tr.appendChild(e_sub);
            e_ses = document.createElement("td");
            e_ses.innerHTML = ses;
            e_tr.appendChild(e_ses);
            for(var proc in e_cols){
                e_td = document.createElement("td");
                e_td.classList = "text-center";
                e_i = document.createElement("i");
                e_i.classList = "bi";
                e_i.setAttribute("font-size", "2em");
                val = r_data_j[id][ses][e_cols[proc]];
                console.log(val);
                switch(val) {
                    case "yes":
                        e_i.classList.add("bi-check-circle-fill");
                        e_i.classList.add("ok");                     
                        break;
                    case "no":
                        e_i.classList.add("bi-x-circle-fill");
                        e_i.classList.add("fail");                                     
                        break;
                    case "running":
                        e_i.classList.add("bi-arrow-repeat");
                        e_i.classList.add("running");                                     
                        break;
                    default:
                        e_i.classList.add("bi-question-circle-fill");
                        e_i.classList.add("unknown");                    
                    }
                e_td.appendChild(e_i);
                e_tr.appendChild(e_td);
            }
        }
    }

};

// GETTING DATA FROM SYSTEM FILES //
async function get_process() {
    const r_process = await fetch("./json/process.json");
    r_process_j = await r_process.json();
    let e_table = document.getElementById("tsv");
    var e_head = document.createElement("thead");
    e_head.classList = "thead-dark ";
    var e_thead_tr = document.createElement("tr");
    let e_cols = ['subject_id', 'session'];
    e_cols = e_cols.concat(r_process_j.columns)
    for(var i in e_cols){
        var e_thead_tr_th = document.createElement("th");
        e_thead_tr_th.setAttribute("scope", "col");
        e_thead_tr_th.classList = "sticky-top";
        e_thead_tr_th.innerHTML = e_cols[i].replaceAll("_", " ");
        e_thead_tr.appendChild(e_thead_tr_th);
    }
    e_head.appendChild(e_thead_tr);
    e_table.appendChild(e_head);
};

// Start the whole thing, grab data list!
get_process();
get_data();
