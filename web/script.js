

 async function SendData(data,cb) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (cb) {
                cb(xhr.responseText)
            }
        }
    }
    xhr.open("POST", 'https://renzu_multicharacter/nuicb', true)
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(data))
}
let getEl = function( id ) { return document.getElementById( id )}
let myForm = getEl('registerf')
let chosenslot = 1
let characters = {}

const toDataURL = url => fetch(url)
  .then(response => response.blob())
  .then(blob => new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onloadend = () => resolve(reader.result)
    reader.onerror = reject
    reader.readAsDataURL(blob)
}))

let pedshots = {}
window.addEventListener('message', function (table) {
    let event = table.data;
    if (event.fade) {
        getEl('body').style.display = 'block'
        getEl('logocontainer').style.display = 'none'
        getEl('loading').style.display = 'block'
        getEl('body').style.background = 'rgba(0, 0, 0, 1.0)'
    } else if (event.fade === false) {
        getEl('loading').style.display = 'none'
        getEl('body').style.background = 'rgba(0, 0, 0, 0.0)'
    }
    if (event.pedshots) {
        if (event.default) {
            pedshots[event.slot] = '/web/ped.jpg'
        } else if (pedshots[event.slot] === undefined || pedshots[event.slot] === '/web/ped.jpg') {
            toDataURL(`https://nui-img/${event.pedshots}/${event.pedshots}?${Date.now()}`)
            .then(dataUrl => {
                pedshots[event.slot] = dataUrl
                console.log(`https://nui-img/${event.pedshots}/${event.pedshots}?${Date.now()}`)
            })
        }
    }
    if (event.showui) {
        getEl('characters').innerHTML = ''
        getEl('body').style.display = 'block'
        getEl('multi').style.display = 'none'
        getEl('logocontainer').style.display = 'none'
        getEl('charinfo').style.display = 'none'
        getEl('option').style.display = 'none'
        getEl('logocontainer').style.width = '100%'
        getEl('logocontainer').style.right = 'auto'
        getEl('register').style.display = 'none'
    }
    if (event.delete === false) {
        getEl('deletebutton').style.display = 'none'
        getEl('deletecancel').style.transform = 'translate(0, 50px)'
        getEl('confirm').style.textAlign = 'center'
        getEl('candelete').innerHTML = 'Player cannot delete characters. Contact administrator'
    }
    if (event.show === true) {
        getEl('multi').style.display = 'grid'
    } else if (event.show === false) {
        getEl('multi').style.display = 'none'
    }

    if (event.showlogo === true) {   
        getEl('logocontainer').style.top = '20%'
        getEl('logocontainer').style.display = 'inline-block'
    } else if (event.showlogo === false) {
        getEl('logocontainer').style.display = 'inline-block'
        getEl('logocontainer').style.width = '45vh'
        getEl('logocontainer').style.right = '15%'
        getEl('logocontainer').style.top = '35%'
    }
    if (event.data) {
        let chars = event.data?.characters || {}
        characters = chars
        if (event.data.slots === undefined) { event.data.slots = 5 }
        for (var i = 0; i < event.data.slots; i++) {
            if (!chars[i]) {
                chars[i] = {name : 'EMPTY SLOT'}
            } else if (chars[i] && chars[i].name === undefined) {
                chars[i] = {name : 'EMPTY SLOT'}
            }
        }
        for (const i in chars) {
            let index = i
            let ui = `<div class="char__card">
            <div class="char__data"  onclick="showchar('${index}')">
                <img src="${pedshots[index]}" alt="" class="char__img" onerror="this.src='/web/ped.jpg';">
                <div id="playerinfo">
                <h1 class="char__name">${chars[index]?.name ? chars[index].name : 'Empty Slot'}</h1>
                <span class="char__profession">${chars[index]?.job ? chars[index].job : ''}</span>
                </div>
            </div>

            <div class="extras" id="extras_${i}">
            </div>
            </div>`
            getEl('characters').insertAdjacentHTML("beforeend", ui)
            for (const ex in chars[index]?.extras || {}) {
                if (chars[index].extras[ex]) {
                    let ui = `<a href="#" class="char__extras with-tooltip" data-tooltip-content="${ex}">${event.data.extras[ex]}</a>`
                    getEl(`extras_${i}`).insertAdjacentHTML("beforeend", ui)
                }
            }
        }

    }
    if (event.showcharacter?.showoptions === 'existing') {
        getEl('delete').style.display = 'inline-block'
        getEl('register').style.display = 'none'
        getEl('charinfo').style.display = 'unset'
        getEl('logocontainer').style.display = 'none'
        getEl('option').style.display = 'inline-block'
        getEl('registercustom').style.display = 'none'
        chosenslot = event.showcharacter.slot
        ShowInfos()
    } else if (event.showcharacter?.showoptions === 'new') {
        chosenslot = event.showcharacter.slot
        if (event.showcharacter.customregister) {
            getEl('delete').style.display = 'none'
            getEl('charinfo').style.display = 'none'
            getEl('logocontainer').style.display = 'none'
            getEl('option').style.display = 'none'
            getEl('registercustom').style.display = 'block'
        } else if (event.showcharacter.customregister === false) {
            getEl('register').style.display = 'flex'
            getEl('delete').style.display = 'none'
            getEl('charinfo').style.display = 'none'
            getEl('logocontainer').style.display = 'none'
            getEl('option').style.display = 'none'
        }
    }
})

function ShowInfos() {
    getEl('infos').innerHTML = ''
    let id = chosenslot-1
    let infos = {}
    for (const i in characters[id]) {
        let data = characters[id][i]
        if (i === 'name') {
            infos[0] = {label : '<i class="fas fa-id-card"></i> Name', data : data}
        }
        if (i === 'job') {
            infos[1] = {label : '<i class="fas fa-briefcase"></i> Job', data : data}
        }
        if (i === 'grade') {
            infos[2] = {label : '<i class="fas fa-level-up-alt"></i> Grade', data : data}
        }
        if (i === 'sex') {
            infos[3] = {label : '<i class="fas fa-venus-mars"></i> Sex', data : data}
        }
        if (i === 'money') {
            infos[4] = {label : '<i class="fas fa-wallet"></i> Money', data : numberWithCommas(data)}
        }
        if (i === 'bank') {
            infos[5] = {label : '<i class="fas fa-piggy-bank"></i> Bank', data : numberWithCommas(data)}
        }
        if (i === 'dateofbirth') {
            infos[6] = {label : '<i class="fas fa-calendar-week"></i> Date of Birth', data : data}
        }
    }
    for (const i in infos) {
        let ui = `<div style="justify-content: space-between!important;border-bottom: 1px solid #dee2e6!important;padding-bottom: 0.5rem!important;margin-top: 1rem!important;align-items: center!important;display: flex!important;width: 300px;">
                <h1 class="char__name">${infos[i].label}</h1>
                <span class="char__profession">${infos[i].data}</span>
            </div>`
        getEl('infos').insertAdjacentHTML("beforeend", ui)
    }    
}

function chooseslot() {
    getEl('body').style.display = 'none'
    return SendData({msg: 'chooseslot', slot : chosenslot})
}

function confirm(show) {
    if (show) {
        getEl('confirm').style.display = 'block'
        SendData({msg: 'deleteattempt'})
    } else {
        getEl('confirm').style.display = 'none'
    }
}

function deletechar() {
    getEl('confirm').style.display = 'none'
    return SendData({msg: 'deletechar', slot : chosenslot})
}

function showchar(slot) {
    slot = +slot + 1
    chosenslot = slot
    myForm.reset()
    return SendData({msg: 'showchar', slot : chosenslot})
}

function register() {
    let formData = new FormData(myForm);
    let data = Object.fromEntries(formData)
    let login = true
    for (const i in data) {
        if(data[i] === '') {
            login = false
            getEl(i).style.borderColor = 'red'
            getEl(i).style.borderStyle = 'outset'
            setTimeout(() => {
                getEl(i).style.borderColor = 'unset'
                getEl(i).style.borderStyle = 'unset'
            }, 2000)
        }
    }
    if (login) {
        getEl('body').style.display = 'none'
        myForm.reset()
        return SendData({msg: 'create', info : data, slot: chosenslot})
    }
}

function registercustom() {
    getEl('body').style.display = 'none'
    getEl('registercustom').style.display = 'none'
    return SendData({msg: 'create', info : {sex : 'm'}, slot: chosenslot})
}

function sex(str) {
    return SendData({msg: 'sex', sex : str, slot: chosenslot})
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

var select = document.getElementById("selectCountry")
var countries = new Array("Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Greenland", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, North", "Korea, South", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Mongolia", "Morocco", "Monaco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Samoa", "San Marino", " Sao Tome", "Saudi Arabia", "Senegal", "Serbia and Montenegro", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe");
    
for (var i = 0; i < countries.length; i++) {
    
    var option = document.createElement("option"); 
    var txt = document.createTextNode(countries[i]); 
    option.appendChild(txt); 
    option.setAttribute("value",countries[i])
    select.insertBefore(option,select.lastChild)
}