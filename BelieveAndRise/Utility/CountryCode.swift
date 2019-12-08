//
//  CountryCode.swift
//  BelieveAndRise
//
//  Created by Belmakor on 11/07/2016.
//  Copyright © 2016 MasterBel2. All rights reserved.
//

import Foundation

/// A list of countries associated with their two-letter code.
enum CountryCode: String {

    case AD
    case AE
    case AF
    case AG
    case AI
    case AL
    case AM
    case AO
    case AQ
    case AR
    case AS
    case AT
    case AU
    case AW
    case AX
    case AZ
    case BA
    case BB
    case BD
    case BE
    case BF
    case BG
    case BH
    case BI
    case BJ
    case BL
    case BM
    case BN
    case BO
    case BQ
    case BR
    case BS
    case BT
    case BV
    case BW
    case BY
    case BZ
    case CA
    case CC
    case CD
    case CF
    case CG
    case CH
    case CI
    case CK
    case CL
    case CM
    case CN
    case CO
    case CR
    case CU
    case CV
    case CW
    case CX
    case CY
    case CZ
    case DE
    case DJ
    case DK
    case DM
    case DO
    case DZ
    case EC
    case EE
    case EG
    case EH
    case ER
    case ES
    case ET
    case FI
    case FJ
    case FK
    case FM
    case FO
    case FR
    case GA
    case GB
    case GD
    case GE
    case GF
    case GG
    case GH
    case GI
    case GL
    case GM
    case GN
    case GP
    case GQ
    case GR
    case GS
    case GT
    case GU
    case GW
    case GY
    case HK
    case HM
    case HN
    case HR
    case HT
    case HU
    case ID
    case IE
    case IL
    case IM
    case IN
    case IO
    case IQ
    case IR
    case IS
    case IT
    case JE
    case JM
    case JO
    case JP
    case KE
    case KG
    case KH
    case KI
    case KM
    case KN
    case KP
    case KR
    case KW
    case KY
    case KZ
    case LA
    case LB
    case LC
    case LI
    case LK
    case LR
    case LS
    case LT
    case LU
    case LV
    case LY
    case MA
    case MC
    case MD
    case ME
    case MF
    case MG
    case MH
    case MK
    case ML
    case MM
    case MN
    case MO
    case MP
    case MQ
    case MR
    case MS
    case MT
    case MU
    case MV
    case MW
    case MX
    case MY
    case MZ
    case NA
    case NC
    case NE
    case NF
    case NG
    case NI
    case NL
    case NO
    case NP
    case NR
    case NU
    case NZ
    case OM
    case PA
    case PE
    case PF
    case PG
    case PH
    case PK
    case PL
    case PM
    case PN
    case PR
    case PS
    case PT
    case PW
    case PY
    case QA
    case RE
    case RO
    case RS
    case RU
    case RW
    case SA
    case SB
    case SC
    case SD
    case SE
    case SG
    case SH
    case SI
    case SJ
    case SK
    case SL
    case SM
    case SN
    case SO
    case SR
    case SS
    case ST
    case SV
    case SX
    case SY
    case SZ
    case TC
    case TD
    case TF
    case TG
    case TH
    case TJ
    case TK
    case TL
    case TM
    case TN
    case TO
    case TR
    case TT
    case TV
    case TW
    case TZ
    case UA
    case UG
    case UM
    case US
    case UY
    case UZ
    case VA
    case VC
    case VE
    case VG
    case VI
    case VN
    case VU
    case WF
    case WS
    case YE
    case YT
    case ZA
    case ZM
    case ZW

    var name: String {
        switch self {

        case .AD: return "Andorra"
        case .AE: return "United Arab Emirates"
        case .AF: return "Afghanistan"
        case .AG: return "Antigua And Barbuda"
        case .AI: return "Anguilla"
        case .AL: return "Albania"
        case .AM: return "Armenia"
        case .AO: return "Angola"
        case .AQ: return "Antarctica"
        case .AR: return "Argentina"
        case .AS: return "American Samoa"
        case .AT: return "Austria"
        case .AU: return "Australia"
        case .AW: return "Aruba"
        case .AX: return "Åland Islands"
        case .AZ: return "Azerbaijan"
        case .BA: return "Boznia And Herzegovina"
        case .BB: return "Barbados"
        case .BD: return "Bangladesh"
        case .BE: return "Belguim"
        case .BF: return "Burkina Faso"
        case .BG: return "Bulgaria"
        case .BH: return "Bahrain"
        case .BI: return "Burundi"
        case .BJ: return "Benin"
        case .BL: return "Saint Barthélemy"
        case .BM: return "Bermuda"
        case .BN: return "Brunei Darussalam"
        case .BO: return "Bolivia, Plurinational State of"
        case .BQ: return "Bonaire, Sint Eustatius and Saba"
        case .BR: return "Brazil"
        case .BS: return "Bahamas"
        case .BT: return "Bhutan"
        case .BV: return "Bouvet Island"
        case .BW: return "Botswana"
        case .BY: return "Belarus"
        case .BZ: return "Belize"
        case .CA: return "Canada"
        case .CC: return "Cocos (Keeling) Islands"
        case .CD: return "Congo, Democratic Reublic of the"
        case .CF: return "Central African Republic"
        case .CG: return "Congo"
        case .CH: return "Switzerland"
        case .CI: return "Côte d'Ivoire"
        case .CK: return "Cook Islands"
        case .CL: return "Chile"
        case .CM: return "Cameroon"
        case .CN: return "China"
        case .CO: return "Colombia"
        case .CR: return "Costa Rica"
        case .CU: return "Cuba"
        case .CV: return "Cabo Verde"
        case .CW: return "Curaçao"
        case .CX: return "Christmas Island"
        case .CY: return "Cyprus"
        case .CZ: return "Czech Republic"

        case .DE: return "Germany"
        case .DJ: return "Djibouti"
        case .DK: return "Denmark"
        case .DM: return "Dominica"
        case .DO: return "Dominican Republic"
        case .DZ: return "Algeria"

        case .EC: return "Ecaudor"
        case .EE: return "Estonia"
        case .EG: return "Egypt"
        case .EH: return "WesternSahara"
        case .ER: return "Eritrea"
        case .ES: return "Spain"
        case .ET: return "Ethiopia"

        case .FI: return "Finland"
        case .FJ: return "Fiji"
        case .FK: return "Falkland Islands (Malvinas)"
        case .FM: return "Federated States of Micronesia"
        case .FO: return "Faroe Islands"
        case .FR: return "France"

        case .GA: return "Gabon"
        case .GB: return "United Kingdom"
        case .GD: return "Grenada"
        case .GE: return "Georgia"
        case .GF: return "French Guiana"
        case .GG: return "Guernsey"
        case .GH: return "Ghana"
        case .GI: return "Gibraltar"
        case .GL: return "Greenland"
        case .GM: return "Gambia"
        case .GN: return "Guinea"
        case .GP: return "Guadeloupe"
        case .GQ: return "Equatorial Guinea"
        case .GR: return "Greece"
        case .GS: return "South Georgia and the South Sandwich Islands"
        case .GT: return "Guatemala"
        case .GU: return "Guam"
        case .GW: return "Guinea-Bissau"
        case .GY: return "Guyana"

        case .HK: return "Hong Kong"
        case .HM: return "Heard Island and McDonald Islands"
        case .HN: return "Honduras"
        case .HR: return "Croatia"
        case .HT: return "Haiti"
        case .HU: return "Hugary"
        case .ID: return "Indonesia"
        case .IE: return "Ireland"
        case .IL: return "Israel"
        case .IM: return "Isle of Man"
        case .IN: return "India"
        case .IO: return "British Indian Ocean Territory"
        case .IQ: return "Iraq"
        case .IR: return "Iran"
        case .IS: return "Iceland"
        case .IT: return "Italy"
        case .JE: return "Jersey"
        case .JM: return "Jamaica"
        case .JO: return "Jordan"
        case .JP: return "Japan"
        case .KE: return "Kenya"
        case .KG: return "Kyrgyzstan"
        case .KH: return "Camodia"
        case .KI: return "Kiribati"
        case .KM: return "Comoros"
        case .KN: return "Saint Kitts and Nevis"
        case .KP: return "North Korea"
        case .KR: return "South Korea"
        case .KW: return "Kuwait"
        case .KY: return "Cayman Islands"
        case .KZ: return "Kazakhstan"
        case .LA: return "Lao People's Democratic Republic"
        case .LB: return "Lebanon"
        case .LC: return "Saint Lucia"
        case .LI: return "Liechtenstein"
        case .LK: return "Sri Lanka"
        case .LR: return "Liberia"
        case .LS: return "Lesotho"
        case .LT: return "Lithuania"
        case .LU: return "Luxembourg"
        case .LV: return "Latvia"
        case .LY: return "Libya"
        case .MA: return "Morocco"
        case .MC: return "Monaco"
        case .MD: return "Moldova"
        case .ME: return "Montenegro"
        case .MF: return "Saint Martin (French)"
        case .MG: return "Madagascar"
        case .MH: return "Marshall Islands"
        case .MK: return "Macedonia"
        case .ML: return "Mali"
        case .MM: return "Myanmar"
        case .MN: return "Mongolia"
        case .MO: return "Macao"
        case .MP: return "Northern Mariana Islands"
        case .MQ: return "Martinique"
        case .MR: return "Mauritania"
        case .MS: return "Montserrat"
        case .MT: return "Malta"
        case .MU: return "Mauritius"
        case .MV: return "Maldives"
        case .MW: return "Malawi"
        case .MX: return "Mexico"
        case .MY: return "Malaysia"
        case .MZ: return "Mozambique"
        case .NA: return "Namibia"
        case .NC: return "New Caledonia"
        case .NE: return "Niger"
        case .NF: return "Norfolk Island"
        case .NG: return "Nigeria"
        case .NI: return "Nicaragua"
        case .NL: return "Netherlands"
        case .NO: return "Norway"
        case .NP: return "Nepal"
        case .NR: return "Nauru"
        case .NU: return "Niue"
        case .NZ: return "New Zealand"
        case .OM: return "Oman"
        case .PA: return "Panama"
        case .PE: return "Peru"
        case .PF: return "French Polynesia"
        case .PG: return "Papua New Guinea"
        case .PH: return "Philippines"
        case .PK: return "Pakistan"
        case .PL: return "Poland"
        case .PM: return "Saint Pierre and Miquelon"
        case .PN: return "Pitcairn"
        case .PR: return "Puerto Rico"
        case .PS: return "Palestine"
        case .PT: return "Portugal"
        case .PW: return "Palau"
        case .PY: return "Paraguay"
        case .QA: return "Qatar"
        case .RE: return "Réunion"
        case .RO: return "Romania"
        case .RS: return "Serbia"
        case .RU: return "Russian Federation"
        case .RW: return "Rwanda"
        case .SA: return "Saudi Arabia"
        case .SB: return "Solomon Islands"
        case .SC: return "Seychelles"
        case .SD: return "Sudan"
        case .SE: return "Sweden"
        case .SG: return "Singapore"
        case .SH: return "Saint Helena, Ascension and Tristan da Cunha"
        case .SI: return "Slovenia"
        case .SJ: return "Svalbard and Jan Mayen"
        case .SK: return "Slovakia"
        case .SL: return "Sierra Leone"
        case .SM: return "San Marino"
        case .SN: return "Senegal"
        case .SO: return "Somalia"
        case .SR: return "Suriname"
        case .SS: return "South Sudan"
        case .ST: return "Sao Tome and Principe"
        case .SV: return "El Salvador"
        case .SX: return "Sint Maarten (Dutch)"
        case .SY: return "Syria"
        case .SZ: return "Swaziland"
        case .TC: return "Turks and Caicos Islands"
        case .TD: return "Chad"
        case .TF: return "French Southern Territories"
        case .TG: return "Togo"
        case .TH: return "Thailand"
        case .TJ: return "Tajikistan"
        case .TK: return "Tokelau"
        case .TL: return "Timor-Leste"
        case .TM: return "Turkmenistan"
        case .TN: return "Tunisia"
        case .TO: return "Tonga"
        case .TR: return "Turkey"
        case .TT: return "Trinidad and Tobago"
        case .TV: return "Tuvalu"
        case .TW: return "Taiwan"
        case .TZ: return "Tanzania"
        case .UA: return "Ukraine"
        case .UG: return "Uganda"
        case .UM: return "United States Minor Outlying Islands"
        case .US: return "United States of America"
        case .UY: return "Urugay"
        case .UZ: return "Uzbekistan"
        case .VA: return "Holy See"
        case .VC: return "Saint Vincent and the Grenadines"
        case .VE: return "Venezuela"
        case .VG: return "British Virgin Islands"
        case .VI: return "Virgin Islands (US)"
        case .VN: return "Vietnam"
        case .VU: return "Vanuatu"
        case .WF: return "Wallis and Futuna"
        case .WS: return "Samoa"
        case .YE: return "Yemen"
        case .YT: return "Mayotte"
        case .ZA: return "South Africa"
        case .ZM: return "Zambia"
        case .ZW: return "Zimbabwe"
        }
    }

    var flag: String {
        switch self {
        case .AD: return "🇦🇩"
        case .AE: return "🇦🇪"
        case .AF: return "🇦🇫"
        case .AG: return "🇦🇬"
        case .AI: return "🇦🇮"
        case .AL: return "🇦🇱"
        case .AM: return "🇦🇲"
        case .AO: return "🇦🇴"
        case .AQ: return "🇦🇶"
        case .AR: return "🇦🇷"
        case .AS: return "🇦🇸"
        case .AT: return "🇦🇹"
        case .AU: return "🇦🇺"
        case .AW: return "🇦🇼"
        case .AX: return "🇦🇽"
        case .AZ: return "🇦🇿"
        case .BA: return "🇧🇦"
        case .BB: return "🇧🇧"
        case .BD: return "🇧🇩"
        case .BE: return "🇧🇪"
        case .BF: return "🇧🇫"
        case .BG: return "🇧🇬"
        case .BH: return "🇧🇭"
        case .BI: return "🇧🇮"
        case .BJ: return "🇧🇯"
        case .BL: return "🇧🇱"
        case .BM: return "🇧🇲"
        case .BN: return "🇧🇳"
        case .BO: return "🇧🇴"
        case .BQ: return "🇧🇶"
        case .BR: return "🇧🇷"
        case .BS: return "🇧🇸"
        case .BT: return "🇧🇹"
        case .BV: return "🇳🇴" // Norwegian flag
        case .BW: return "🇧🇼"
        case .BY: return "🇧🇾"
        case .BZ: return "🇧🇿"
        case .CA: return "🇨🇦"
        case .CC: return "🇨🇨"
        case .CD: return "🇨🇩"
        case .CF: return "🇨🇫"
        case .CG: return "🇨🇬"
        case .CH: return "🇨🇭"
        case .CI: return "🇨🇮"
        case .CK: return "🇨🇰"
        case .CL: return "🇨🇱"
        case .CM: return "🇨🇲"
        case .CN: return "🇨🇳"
        case .CO: return "🇨🇴"
        case .CR: return "🇨🇷"
        case .CU: return "🇨🇺"
        case .CV: return "🇨🇻"
        case .CW: return "🇨🇼"
        case .CX: return "🇨🇽"
        case .CY: return "🇨🇾"
        case .CZ: return "🇨🇿"
        case .DE: return "🇩🇪"
        case .DJ: return "🇩🇯"
        case .DK: return "🇩🇰"
        case .DM: return "🇩🇲"
        case .DO: return "🇩🇴"
        case .DZ: return "🇩🇿"
        case .EC: return "🇪🇨"
        case .EE: return "🇪🇪"
        case .EG: return "🇪🇬"
        case .EH: return "🇪🇭"
        case .ER: return "🇪🇷"
        case .ES: return "🇪🇸"
        case .ET: return "🇪🇹"
        case .FI: return "🇫🇮"
        case .FJ: return "🇫🇯"
        case .FK: return "🇫🇰"
        case .FM: return "🇫🇲"
        case .FO: return "🇫🇴"
        case .FR: return "🇫🇷"
        case .GA: return "🇬🇦"
        case .GB: return "🇬🇧"
        case .GD: return "🇬🇩"
        case .GE: return "🇬🇪"
        case .GF: return "🇬🇫"
        case .GG: return "🇬🇬"
        case .GH: return "🇬🇭"
        case .GI: return "🇬🇮"
        case .GL: return "🇬🇱"
        case .GM: return "🇬🇲"
        case .GN: return "🇬🇳"
        case .GP: return "🇬🇵"
        case .GQ: return "🇬🇶"
        case .GR: return "🇬🇷"
        case .GS: return "🇬🇸"
        case .GT: return "🇬🇹"
        case .GU: return "🇬🇺"
        case .GW: return "🇬🇼"
        case .GY: return "🇬🇾"
        case .HK: return "🇭🇰"
        case .HM: return "🇦🇺" // Heard Island and McDonald Islands (Australia)
        case .HN: return "🇭🇳"
        case .HR: return "🇭🇷"
        case .HT: return "🇭🇹"
        case .HU: return "🇭🇺"
        case .ID: return "🇮🇩"
        case .IE: return "🇮🇪"
        case .IL: return "🇮🇱"
        case .IM: return "🇮🇲"
        case .IN: return "🇮🇳"
        case .IO: return "🇮🇴"
        case .IQ: return "🇮🇶"
        case .IR: return "🇮🇷"
        case .IS: return "🇮🇸"
        case .IT: return "🇮🇹"
        case .JE: return "🇯🇪"
        case .JM: return "🇯🇲"
        case .JO: return "🇯🇴"
        case .JP: return "🇯🇵"
        case .KE: return "🇰🇪"
        case .KG: return "🇰🇬"
        case .KH: return "🇰🇭"
        case .KI: return "🇰🇲"
        case .KM: return "🇰🇲"
        case .KN: return "🇰🇳"
        case .KP: return "🇰🇵"
        case .KR: return "🇰🇷"
        case .KW: return "🇰🇼"
        case .KY: return "🇰🇾"
        case .KZ: return "🇰🇿"
        case .LA: return "🇱🇦"
        case .LB: return "🇱🇧"
        case .LC: return "🇱🇨"
        case .LI: return "🇱🇮"
        case .LK: return "🇱🇰"
        case .LR: return "🇱🇷"
        case .LS: return "🇱🇸"
        case .LT: return "🇱🇹"
        case .LU: return "🇱🇺"
        case .LV: return "🇱🇻"
        case .LY: return "🇱🇾"
        case .MA: return "🇲🇦"
        case .MC: return "🇲🇨"
        case .MD: return "🇲🇩"
        case .ME: return "🇲🇪"
        case .MF: return "🇫🇷" // French
        case .MG: return "🇲🇬"
        case .MH: return "🇲🇭"
        case .MK: return "🇲🇰"
        case .ML: return "🇲🇱"
        case .MM: return "🇲🇲"
        case .MN: return "🇲🇳"
        case .MO: return "🇲🇴"
        case .MP: return "🇲🇵"
        case .MQ: return "🇲🇶"
        case .MR: return "🇲🇷"
        case .MS: return "🇲🇸"
        case .MT: return "🇲🇹"
        case .MU: return "🇲🇺"
        case .MV: return "🇲🇻"
        case .MW: return "🇲🇼"
        case .MX: return "🇲🇽"
        case .MY: return "🇲🇾"
        case .MZ: return "🇲🇿"
        case .NA: return "🇳🇦"
        case .NC: return "🇳🇨"
        case .NE: return "🇳🇪"
        case .NF: return "🇳🇫"
        case .NG: return "🇳🇬"
        case .NI: return "🇳🇮"
        case .NL: return "🇳🇱"
        case .NO: return "🇳🇴"
        case .NP: return "🇳🇵"
        case .NR: return "🇳🇷"
        case .NU: return "🇳🇺"
        case .NZ: return "🇳🇿"
        case .OM: return "🇷🇴"
        case .PA: return "🇵🇦"
        case .PE: return "🇵🇪"
        case .PF: return "🇵🇫"
        case .PG: return "🇵🇬"
        case .PH: return "🇵🇭"
        case .PK: return "🇵🇰"
        case .PL: return "🇵🇱"
        case .PM: return "🇵🇲"
        case .PN: return "🇵🇳"
        case .PR: return "🇵🇷"
        case .PS: return "🇵🇸"
        case .PT: return "🇵🇹"
        case .PW: return "🇵🇼"
        case .PY: return "🇵🇾"
        case .QA: return "🇶🇦"
        case .RE: return "🇷🇪"
        case .RO: return "🇷🇴"
        case .RS: return "🇷🇸"
        case .RU: return "🇷🇺"
        case .RW: return "🇷🇼"
        case .SA: return "🇸🇦"
        case .SB: return "🇸🇧"
        case .SC: return "🇸🇨"
        case .SD: return "🇸🇩"
        case .SE: return "🇸🇪"
        case .SG: return "🇸🇬"
        case .SH: return "🇸🇭"
        case .SI: return "🇸🇮"
        case .SJ: return "🇳🇴" // Norwegian territories
        case .SK: return "🇸🇰"
        case .SL: return "🇸🇱"
        case .SM: return "🇸🇲"
        case .SN: return "🇸🇳"
        case .SO: return "🇸🇴"
        case .SR: return "🇸🇷"
        case .SS: return "🇸🇸"
        case .ST: return "🇸🇹"
        case .SV: return "🇸🇻"
        case .SX: return "🇸🇽"
        case .SY: return "🇸🇾"
        case .SZ: return "🇸🇿"
        case .TC: return "🇹🇨"
        case .TD: return "🇹🇩"
        case .TF: return "🇹🇫"
        case .TG: return "🇹🇬"
        case .TH: return "🇹🇭"
        case .TJ: return "🇹🇯"
        case .TK: return "🇹🇰"
        case .TL: return "🇹🇱"
        case .TM: return "🇹🇲"
        case .TN: return "🇹🇳"
        case .TO: return "🇹🇴"
        case .TR: return "🇹🇷"
        case .TT: return "🇹🇹"
        case .TV: return "🇹🇻"
        case .TW: return "🇹🇼"
        case .TZ: return "🇹🇿"
        case .UA: return "🇺🇦"
        case .UG: return "🇺🇬"
        case .UM: return "🇺🇸" // US islands
        case .US: return "🇺🇸"
        case .UY: return "🇺🇾"
        case .UZ: return "🇺🇿"
        case .VA: return "🇻🇦"
        case .VC: return "🇻🇨"
        case .VE: return "🇻🇪"
        case .VG: return "🇻🇬"
        case .VI: return "🇻🇮"
        case .VN: return "🇻🇳"
        case .VU: return "🇻🇺"
        case .WF: return "🇼🇫"
        case .WS: return "🇼🇸"
        case .YE: return "🇾🇪"
        case .YT: return "🇾🇹"
        case .ZA: return "🇿🇦"
        case .ZM: return "🇿🇲"
        case .ZW: return "🇿🇼"
        }
    }
}
