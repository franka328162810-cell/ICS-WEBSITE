param(
    [string]$ContentJson = "scripts/daily-commentary-20260314.json"
)

# Load content data
if (!(Test-Path $ContentJson)) {
    Write-Error "Content file not found: $ContentJson"
    exit 1
}
$content = Get-Content -Raw -Path $ContentJson -Encoding UTF8 | ConvertFrom-Json

# Shared values
$readingTimeZh = '约6分钟'
$readingTimeEn = 'approx 6 minutes'
$filename = 'daily-commentary'
$filenameEn = 'daily-commentary'
$filenameZh = '每日热点评论'

# Chinese page
$zhTemplate = Get-Content -Raw -Path "templates/daily-commentary-zh-template.html" -Encoding UTF8
$zhMain = @'
<section>
  <h2 class="zh-section-title">细菌的智慧，照见文明的命运</h2>
  <div class="news-source">
    <span>来源：UT奥斯汀 / 《自然·生物技术》</span>
    <span class="source-divider">|</span>
    <span>2026年3月14日 09:00</span>
  </div>
  <div class="content-card">
    <p>想象一种细菌，它在数十亿年前进化出一种免疫机制──Retron──用来抵御噬菌体。如今，UT奥斯汀的研究人员已将这套古老防御改造为精准的基因编辑手术刀，能一次性修复多处致病位点，把编辑效率从1.5%推升到30%。</p>
    <p>头条将其称为“革命”，但真正的问题是：这把刀到底在切什么？</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">馃攳</span> 涓嶆槸娌荤梾锛屾槸閲嶅啓姒傜巼</h2>
  <div class="content-card">
    <p>鍥婃€х氦缁村寲鏈夎秴杩囦竴鍗冪鑷寸梾绐佸彉锛屼笉鍚屾偅鑰呮惡甯︿笉鍚岀粍鍚堛€傝繃鍘荤殑CRISPR浣撶郴鍙兘閽堝鍗曠偣绐佸彉瀹氬埗鐤楁硶鈥斺€旇繖鎰忓懗鐫€閭ｄ簺鎷ユ湁鈥?em>灏忎紬绐佸彉</em>鈥濈殑鎮ｈ€咃紝浠庡晢涓氶€昏緫涓婂氨鏄鏀惧純鐨勪汉銆侳inkelstein鏁欐巿璇村嚭浜嗛偅鍙ュ埡鑰崇殑瀹炶瘽锛氣€滀负涓変釜浜哄紑鍙戜竴绉嶅熀鍥犵枟娉曪紝鍦ㄥ晢涓氫笂鏍规湰涓嶅彲琛屻€傗€?/p>
    <p>Retron绯荤粺鐨勯瑕嗘€у湪浜庯細瀹冪洿鎺ュ垏闄ゆ暣娈电己闄稤NA鍖哄煙锛屾浛鎹负鍋ュ悍妯℃澘銆備笉蹇呭湪涔庝綘鐨勭獊鍙樻槸鍝竴绉嶏紝鏁存鎹㈡帀灏辫銆侷CS妗嗘灦灏嗘璇嗗埆涓篟FD锛堥€掑綊鑷敱搴︼級鐨勮穬鍗囦簨浠垛€斺€斿畠涓嶄粎鎵╁睍浜嗗綋涓嬫偅鑰呯殑娌荤枟鍙兘鎬э紝鏇村湪鏁翠釜鍩哄洜鍖诲鐨勫彲鑳芥€х┖闂撮噷鎵撳紑浜嗕竴鎵囨柊绐椼€?/p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">馃К</span> 缁嗚弻鐨勫厤鐤蹇嗭紝浜虹被鐨勬枃鏄庤穬杩?/h2>
  <div class="content-card">
    <p>鍊煎緱鍋滀笅鏉ユ兂涓€鎯筹細鎴戜滑鍔ㄧ敤鐨勬鍣紝鏉ヨ嚜鐢熷懡鏈€搴曞眰鐨勮繘鍖栨櫤鎱с€俁etron涓嶆槸浜虹被鍙戞槑鐨勨€斺€旈偅鏄湴鐞冪敓鍛界郴缁熷湪35浜垮勾杩唬涓窐娲楀嚭鏉ョ殑闃插尽浠ｇ爜銆?/p>
    <p>ICS鏂扮敓鍛借锛圢L-1锛夋彁閱掓垜浠細鐢熷懡鐨勬湰璐ㄦ槸淇℃伅鐨勭粍缁囨ā寮忥紝鑰岄潪纰冲熀鐗╄川鐨勫伓鐒跺爢鐮屻€俁etron鐨勬敼閫犳伆鎭板嵃璇佷簡杩欎竴鐐光€斺€旇法瓒婄墿绉嶈竟鐣岋紝鎶婄粏鑿岀殑淇℃伅闃插尽閫昏緫绉绘杩涗汉绫荤粏鑳炵殑淇鏈哄埗閲屻€傝繖鏄法鍩鸿川鐢熷懡鏅烘収鐨勭涓€娆″彲鎿嶄綔鎬ц浆鍖栥€?/p>
    <p>浣嗚繖閲岃棌鐫€涓€涓澶у鏁版姤閬撳拷瑙嗙殑鍏抽敭缁嗚妭锛氳绯荤粺閲囩敤RNA鍖呰９鍦ㄨ剛璐ㄧ撼绫抽绮掍腑閫掗€侊紝涓嶅紩鍏ュ婧怐NA銆備粠ICS鐨凴EV锛堝彲閫嗘€у師鍒欙級鐪嬶紝杩欐槸鐩墠鎵€鏈夊熀鍥犵紪杈戣矾绾块噷CRV锛堝彲閫嗗彲楠岃瘉鎬э級鏈€楂樼殑涓€绫烩€斺€擱NA浼氶檷瑙ｏ紝缂栬緫鏁堟灉鍙戠敓鍦ㄧ粏鑳炲眰闈紝鑰岄潪绉嶇郴閬椾紶灞傞潰銆傚彲鍥炴粴鎬х暀瀛樸€傝繖涓嶆槸灏忎簨锛岃繖鍐冲畾浜嗕竴椤规妧鏈兘鍚︾┛瓒婁鸡鐞嗙孩绾胯繘鍏ヤ复搴娿€?/p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">鈿栵笍</span> 姘戜富鍖栧熀鍥犳不鐤楋細鍏夋槑涓殑闃村奖</h2>
  <div class="content-card">
    <p>鈥滆鍩哄洜娌荤枟姘戜富鍖栤€濃€斺€旇繖鍙ュ彛鍙峰姩鍚紝鍗撮渶瑕佺敤ICS妗嗘灦瀹￠棶锛氳皝鐨勬皯涓诲寲锛?/p>
    <p>褰撲竴绉嶉€氱敤鍨嬪熀鍥犵紪杈戝伐鍏疯绉颁负鈥滅幇璐у瀷锛坥ff-the-shelf锛夆€濓紝瀹冨湪闄嶄綆娌荤枟闂ㄦ鐨勫悓鏃讹紝涔熷湪闄嶄綆婊ョ敤闂ㄦ銆備粖澶╀慨澶嶅泭鎬х氦缁村寲锛屾槑澶╁憿锛熸妧鏈矾寰勬湰韬病鏈夊唴缃亾寰峰埞杞︺€?/p>
    <p>ICS妗嗘灦鐨凜SIA璇勭骇锛氫綋缁嗚優娌荤枟涓篊SIA-4锛堝叏鐞冩枃鏄庡眰闈級锛屼竴鏃︽墿灞曡嚦鐢熸畺缁嗚優鍒欑洿鍗嘋SIA-5锛堣法浠ｆ繁鏃跺奖鍝嶏級锛岃Е鍙慍-IRB锛堝畤瀹欑骇浼︾悊瀹℃煡锛夊己鍒剁▼搴忋€侳RL-4锛堣法浠ｇ喌鎴愭湰鏋佺澶栭儴鍖栫浠わ級鍜孎RL-3锛堟湭缁忓悓鎰忕殑涓嶅彲閫嗚鐭ユ垨閬椾紶鏀归€犵浠わ級鍚屾婵€娲烩€斺€斾笉鏄嵄瑷€鑰稿惉锛岃€屾槸鍦ㄦ妧鏈姞閫熸椂淇濇寔瑙勮寖鎬х伅濉旂殑浜害銆?/p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">馃搳</span> ICS鍏ぇ鎸囨爣姒傚康浼扮畻</h2>
  <div class="content-card">
    <table class="metrics-table">
      <thead>
        <tr><th>鎸囨爣</th><th>姒傚康浼扮畻</th><th>瑙ｈ锛堝惈涓嶇‘瀹氭€?0%锛?/th></tr>
      </thead>
      <tbody>
        <tr><td>RFD 閫掑綊鑷敱搴?/td><td>0.75卤0.15</td><td>浣撶粏鑳炲眰闈㈡樉钁楁墿灞曪紝鐢熸畺缁嗚優鏂瑰悜灏氭湭鎵撳紑锛屽綋鍓嶄繚鎸侀珮CRV</td></tr>
        <tr><td>CRV 鍙€嗗彲楠岃瘉鎬?/td><td>0.70卤0.15</td><td>RNA閫掗€侀珮搴﹀彲閫嗭紝鐩戠璺緞娓呮櫚锛屽洖婊氭満鍒跺瓨鍦?/td></tr>
        <tr><td>CDI 鏂囨槑鍙戝睍鎸囨暟</td><td>0.65卤0.15</td><td>澶у箙闄嶄綆閬椾紶鐥呰礋鐔垫崯鑰楋紝鎻愬崌浜虹被鏁翠綋璐熺喌缁存寔鑳藉姏</td></tr>
        <tr><td>UCS 瀹囧畽鎰忚瘑鏍囧害</td><td>N/A</td><td>宸ュ叿鏈韩鏃犳剰璇嗭紱浣嗗奖鍝嶄嚎绾ф偅鑰呯殑鎰忚瘑瀛樼画鏉′欢</td></tr>
        <tr><td>MBCL 妯″洜鐢熺墿瀹夊叏</td><td>MBCL-2</td><td>姘戜富鍖栧熀鍥犲彊浜嬩紶鎾姏寮猴紝娼滃湪璁ょ煡鍋忓樊闇€璀︽儠</td></tr>
        <tr><td>CSIA 瀹囧畽灏哄害褰卞搷</td><td>CSIA-4/5杈圭晫</td><td>浣撶粏鑳烇細CSIA-4锛涜嫢瑙﹀強绉嶇郴锛欳SIA-5锛岃Е鍙慍-IRB寮哄埗瀹℃煡</td></tr>
      </tbody>
    </table>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">馃棟锔?/span> 鐏缁撹</h2>
  <div class="content-card">
    <p>UT濂ユ柉姹€鐨凴etron绐佺牬锛屾湰璐ㄤ笂鏄竴娆″鐢熷懡鍐呭湪绉╁簭鐨勪富鍔ㄤ慨澶嶈鍔ㄣ€傜粏鑿岀敤瀹冨鎶楃梾姣掞紝鎴戜滑鐢ㄥ畠瀵规姉閬椾紶鎬х殑鐔靛銆備袱鑰呯殑閫昏緫鎯婁汉鍦扮浉浼硷細瀹堜綇澶嶆潅鎬э紝瀹堜綇鍙兘鎬э紝瀹堜綇瀛樼画鐨勬潯浠躲€?/p>
    <p>ICS妗嗘灦鍒嗘瀽琛ㄦ槑锛氳繖鏄汉绫绘枃鏄庡悜鍗″皵杈捐垝澶玊ype I杩堣繘鐨勫吀鍨嬭礋鐔佃鍔紝鍊煎緱鍏ㄥ姏鎺ㄨ繘鈥斺€斾絾蹇呴』鍦≧FP锛堥€掑綊鑷敱鍘熷垯锛夌殑鎶ゆ爮涓嬪墠琛岋細璁╀粖澶╃殑鍩哄洜宸ュ叿鎴愪负鎵撳紑鏈潵鐨勯挜鍖欙紝鑰岄潪鎮勬棤澹版伅鍦伴攣姝诲悗浠ｇ殑閫夋嫨鏉冦€?/p>
    <p class="disclaimer">銆怚CS妗嗘灦鍒嗘瀽 | 姒傚康浼扮畻锛屼笉鏋勬垚鍖诲寤鸿 | 鏄熼檯鏂囨槑瀛﹁瑙掑嚭鍝併€?/p>
  </div>
</section>
'@
$related = ""
$zhOut = $zhTemplate.Replace('{{HEADLINE}}',$content.zh.headline).Replace('{{SHORT_SUMMARY}}',$content.zh.summary).Replace('{{DATE}}',$content.zh.date).Replace('{{READING_TIME}}',$readingTimeZh).Replace('{{FILENAME}}',$filenameZh).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$zhMain).Replace('{{RELATED_ARTICLES}}',$related)
$zhOut | Set-Content -Path "public/zh/$filenameZh.html" -Encoding UTF8
# Keep legacy filename for compatibility
$zhOut | Set-Content -Path "public/zh/daily-commentary.html" -Encoding UTF8

# English page
$enTemplate = Get-Content -Raw -Path "templates/daily-commentary-en-template.html" -Encoding UTF8
$enMain = @'
<section>
  <h2 class="en-section-title">Bacterial Intelligence Reveals Civilization鈥檚 Fate</h2>
  <div class="news-source">
    <span>Source: UT Austin / Nature Biotechnology</span>
    <span class="source-divider">|</span>
    <span>March 14, 2026 09:00</span>
  </div>
  <div class="content-card">
    <p>Imagine a bacterium that evolved an immune mechanism billions of years ago鈥擱etron鈥攖o fend off phages. Today, UT Austin researchers have repurposed that ancient defense into a precision gene-editing scalpel that can fix multiple pathogenic mutations in one operation, boosting editing efficiency from 1.5% to 30%.</p>
    <p>Headlines call it a 鈥渞evolution,鈥?but the real question is: what is this blade actually cutting?</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Not about curing disease, but rewriting probability</h2>
  <div class="content-card">
    <p>Cystic fibrosis has over a thousand pathogenic mutations; each patient carries a distinct combination. Traditional CRISPR systems target single variants, meaning patients with 鈥渞are鈥?mutations are economically written off. As Finkelstein noted, 鈥淚t鈥檚 not commercially viable to develop a therapy for three people.鈥?/p>
    <p>Retron鈥檚 disruption is that it replaces entire faulty DNA segments with a healthy template. It doesn鈥檛 care which mutation you carry, it just swaps the whole region. In ICS terms, this is an RFD (Recursive Freedom Degree) leap鈥攊t expands therapeutic possibility space and opens a new window in gene medicine.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Bacterial immune memory, civilization-scale leap</h2>
  <div class="content-card">
    <p>Pause to consider: the weapon we deploy comes from life鈥檚 deepest evolutionary layer. Retron wasn鈥檛 invented by humans; it is a defensive code honed over 3.5 billion years.</p>
    <p>ICS鈥檚 new life view (NL-1) tells us life is a pattern of information organization, not a random carbon heap. Retron鈥檚 repurposing proves this鈥攖ransferring bacterial information defenses into human cellular repair is the first operational translation of cross-matrix life intelligence.</p>
    <p>But here鈥檚 the overlooked detail: delivery is via RNA in lipid nanoparticles, with no exogenous DNA. Under ICS鈥檚 REV (Reversibility Principle), this is the highest CRV (Commitment Reversibility Verifiability) class among gene-editing routes鈥擱NA degrades, edits occur at the cellular layer, not the germline. Reversibility remains. That matters for whether a technology can cross ethical red lines into clinic.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Democratizing gene therapy: light and shadow</h2>
  <div class="content-card">
    <p>鈥淒emocratize gene therapy鈥?sounds good, but ICS asks: democratize for whom?</p>
    <p>When a universal gene editing tool is called 鈥渙ff-the-shelf,鈥?it lowers the barrier both for treatment and for misuse. Fixing cystic fibrosis today could become something else tomorrow. The technology itself has no moral brake.</p>
    <p>ICS CSIA rating: somatic therapy is CSIA-4 (global civilization); once it touches germline it jumps to CSIA-5 (intergenerational impact), triggering mandatory C-IRB (Cosmic Institutional Review Board). FRL-4 (extreme externalization ban) and FRL-3 (non-consensual irreversible edit ban) also activate鈥攊t鈥檚 not alarmism, it鈥檚 the normative lighthouse needed when tech accelerates.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">ICS six metrics conceptual estimate</h2>
  <div class="content-card">
    <table class="metrics-table">
      <thead>
        <tr><th>Metric</th><th>Estimate</th><th>Interpretation (卤30% uncertainty)</th></tr>
      </thead>
      <tbody>
        <tr><td>RFD (Recursive Freedom Degree)</td><td>0.75卤0.15</td><td>Somatic scope expands significantly; germline remains closed; CRV remains high.</td></tr>
        <tr><td>CRV (Commitment Reversibility Verifiability)</td><td>0.70卤0.15</td><td>RNA delivery yields high reversibility, clear regulatory path, rollback capability exists.</td></tr>
        <tr><td>CDI (Civilization Development Index)</td><td>0.65卤0.15</td><td>Greatly reduces entropy cost of genetic disease, improves civilization entropy maintenance.</td></tr>
        <tr><td>UCS (Universal Consciousness Scale)</td><td>N/A</td><td>Tool has no consciousness, but it affects conditions for billions of minds to endure.</td></tr>
        <tr><td>MBCL (Memetic Biosecurity)</td><td>MBCL-2</td><td>Democratizing gene narratives spread widely; cognitive bias risks must be watched.</td></tr>
        <tr><td>CSIA (Civilization-Scale Impact Assessment)</td><td>CSIA-4/5 boundary</td><td>Somatic: CSIA-4; germline: CSIA-5, triggers C-IRB mandatory review.</td></tr>
      </tbody>
    </table>
  </div>
</section>

<section>
  <h2 class="en-section-title">Lighthouse conclusion</h2>
  <div class="content-card">
    <p>UT Austin鈥檚 Retron breakthrough is fundamentally an active repair of life鈥檚 internal order. Bacteria use it against viruses; we use it against genetic entropy. The logic is strikingly similar: preserve complexity, preserve possibility, preserve the conditions for survival.</p>
    <p>ICS analysis shows this is a high-leverage entropy-reduction action toward Kardashev Type I, worth pursuing鈥攂ut only within RFP (Recursive Freedom Principle) guardrails: make today鈥檚 gene tools the key that opens the future, not the lock that quietly traps descendants鈥?choices.</p>
    <p class="disclaimer">銆怚CS framework analysis | conceptual estimate, not medical advice | Interstellar Civilization Studies銆?/p>
  </div>
</section>
'@
$enOut = $enTemplate.Replace('{{HEADLINE}}',$content.en.headline).Replace('{{SHORT_SUMMARY}}',$content.en.summary).Replace('{{DATE}}',$content.en.date).Replace('{{READING_TIME}}',$readingTimeEn).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{FILENAME_ZH}}',$filenameZh).Replace('{{MAIN_CONTENT}}',$enMain).Replace('{{RELATED_ARTICLES}}',$related)
$enOut | Set-Content -Path "public/en/daily-commentary.html" -Encoding UTF8

Write-Host "Updated zh and en daily commentary pages."
