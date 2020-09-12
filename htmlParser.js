let music_list_with_category = document.getElementsByClassName("wrapper main_wrapper t_c")[0].children;
outputStr =
    "module Data exposing (songData)\n\nsongData =\n  [";
let category_name = "";
let class_name, music_name, difficult, music_data;
let last_music_name = null;
for(let i = 5; i < music_list_with_category.length-1; i++){
    class_name = music_list_with_category[i].className;
    if(class_name == "screw_block m_15 f_15"){
        category_name = music_list_with_category[i].innerText;
    }else if(class_name == "w_450 m_15 p_r f_0"){
        music_name = music_list_with_category[i].getElementsByClassName("music_name_block t_l f_13 break")[0].innerText;
        difficult = music_list_with_category[i].getElementsByClassName("music_lv_block f_r t_c f_14")[0].innerText;
        is_standard = music_list_with_category[i].querySelector('[src="https://maimaidx.jp/maimai-mobile/img/music_standard.png"]') != null;
        is_dx = music_list_with_category[i].querySelector('[src="https://maimaidx.jp/maimai-mobile/img/music_dx.png"]') != null;
        if(is_dx && is_standard && music_name == last_music_name){
            is_dx = false;
        }
        last_music_name = music_name;
        let bool;
        if(is_dx){
            bool = "True";
        }else{
            bool = "False";
        }
        music_name = music_name.split('"');
        music_name.join('\"');
        outputStr = outputStr + " { musicName = \"" + music_name + "\", difficult = \"" + difficult + "\", isDx = " + bool + " }\n  ,";
    }
}
outputStr = outputStr.substr(0,(outputStr.length-1));
outputStr = outputStr + " ]"
console.log(outputStr);
document.write(outputStr);

const blob = new Blob([outputStr], {type: 'text/plain'});
const url = URL.createObjectURL(blob);
const a = document.createElement("a");
document.body.appendChild(a);
a.download = 'Data.elm';
a.href = url;
a.click();
a.remove();
URL.revokeObjectURL(url);