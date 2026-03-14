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
$readingTime = '约6分钟'
$filename = 'daily-commentary'
$filenameEn = 'daily-commentary'

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
    <p>先给你一个画面：一粒细菌，在数十亿年前演化出一种防御机制——Retron。它的功能不过是对抗噬菌体入侵，守住自己薄薄的细胞壁。然而今天，德克萨斯大学奥斯汀分校的研究团队把这个古老武器改造成了人类医学史上最精准的「基因手术刀」：一次操作，同时修复多个致病突变，细胞编辑效率从1.5%跃升至30%，发表于顶刊《自然·生物技术》。</p>
    <p>媒体标题在喊「革命」，但我们要问一个更深的问题：这把刀，究竟在切什么？</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">🔍</span> 不是治病，是重写概率</h2>
  <div class="content-card">
    <p>囊性纤维化有超过一千种致病突变，不同患者携带不同组合。过去的CRISPR体系只能针对单点突变定制疗法——这意味着那些拥有“<em>小众突变</em>”的患者，从商业逻辑上就是被放弃的人。Finkelstein教授说出了那句刺耳的实话：“为三个人开发一种基因疗法，在商业上根本不可行。”</p>
    <p>Retron系统的颠覆性在于：它直接切除整段缺陷DNA区域，替换为健康模板。不必在乎你的突变是哪一种，整段换掉就行。ICS框架将此识别为RFD（递归自由度）的跃升事件——它不仅扩展了当下患者的治疗可能性，更在整个基因医学的可能性空间里打开了一扇新窗。</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">🧬</span> 细菌的免疫记忆，人类的文明跃迁</h2>
  <div class="content-card">
    <p>值得停下来想一想：我们动用的武器，来自生命最底层的进化智慧。Retron不是人类发明的——那是地球生命系统在35亿年迭代中淘洗出来的防御代码。</p>
    <p>ICS新生命观（NL-1）提醒我们：生命的本质是信息的组织模式，而非碳基物质的偶然堆砌。Retron的改造恰恰印证了这一点——跨越物种边界，把细菌的信息防御逻辑移植进人类细胞的修复机制里。这是跨基质生命智慧的第一次可操作性转化。</p>
    <p>但这里藏着一个被大多数报道忽视的关键细节：该系统采用RNA包裹在脂质纳米颗粒中递送，不引入外源DNA。从ICS的REV（可逆性原则）看，这是目前所有基因编辑路线里CRV（可逆可验证性）最高的一类——RNA会降解，编辑效果发生在细胞层面，而非种系遗传层面。可回滚性留存。这不是小事，这决定了一项技术能否穿越伦理红线进入临床。</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">⚖️</span> 民主化基因治疗：光明中的阴影</h2>
  <div class="content-card">
    <p>“让基因治疗民主化”——这句口号动听，却需要用ICS框架审问：谁的民主化？</p>
    <p>当一种通用型基因编辑工具被称为“现货型（off-the-shelf）”，它在降低治疗门槛的同时，也在降低滥用门槛。今天修复囊性纤维化，明天呢？技术路径本身没有内置道德刹车。</p>
    <p>ICS框架的CSIA评级：体细胞治疗为CSIA-4（全球文明层面），一旦扩展至生殖细胞则直升CSIA-5（跨代深时影响），触发C-IRB（宇宙级伦理审查）强制程序。FRL-4（跨代熵成本极端外部化禁令）和FRL-3（未经同意的不可逆认知或遗传改造禁令）同步激活——不是危言耸听，而是在技术加速时保持规范性灯塔的亮度。</p>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">📊</span> ICS六大指标概念估算</h2>
  <div class="content-card">
    <table class="metrics-table">
      <thead>
        <tr><th>指标</th><th>概念估算</th><th>解读（含不确定性±30%）</th></tr>
      </thead>
      <tbody>
        <tr><td>RFD 递归自由度</td><td>0.75±0.15</td><td>体细胞层面显著扩展，生殖细胞方向尚未打开，当前保持高CRV</td></tr>
        <tr><td>CRV 可逆可验证性</td><td>0.70±0.15</td><td>RNA递送高度可逆，监管路径清晰，回滚机制存在</td></tr>
        <tr><td>CDI 文明发展指数</td><td>0.65±0.15</td><td>大幅降低遗传病负熵损耗，提升人类整体负熵维持能力</td></tr>
        <tr><td>UCS 宇宙意识标度</td><td>N/A</td><td>工具本身无意识；但影响亿级患者的意识存续条件</td></tr>
        <tr><td>MBCL 模因生物安全</td><td>MBCL-2</td><td>民主化基因叙事传播力强，潜在认知偏差需警惕</td></tr>
        <tr><td>CSIA 宇宙尺度影响</td><td>CSIA-4/5边界</td><td>体细胞：CSIA-4；若触及种系：CSIA-5，触发C-IRB强制审查</td></tr>
      </tbody>
    </table>
  </div>
</section>

<section>
  <h2 class="zh-section-title"><span class="section-icon">🗝️</span> 灯塔结语</h2>
  <div class="content-card">
    <p>UT奥斯汀的Retron突破，本质上是一次对生命内在秩序的主动修复行动。细菌用它对抗病毒，我们用它对抗遗传性的熵增。两者的逻辑惊人地相似：守住复杂性，守住可能性，守住存续的条件。</p>
    <p>ICS框架分析表明：这是人类文明向卡尔达舒夫Type I迈进的典型负熵行动，值得全力推进——但必须在RFP（递归自由原则）的护栏下前行：让今天的基因工具成为打开未来的钥匙，而非悄无声息地锁死后代的选择权。</p>
    <p class="disclaimer">【ICS框架分析 | 概念估算，不构成医学建议 | 星际文明学视角出品】</p>
  </div>
</section>
'@
$related = ""
$zhOut = $zhTemplate.Replace('{{HEADLINE}}',$content.zh.headline).Replace('{{SHORT_SUMMARY}}',$content.zh.summary).Replace('{{DATE}}',$content.zh.date).Replace('{{READING_TIME}}',$readingTime).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$zhMain).Replace('{{RELATED_ARTICLES}}',$related)
$zhOut | Set-Content -Path "public/zh/daily-commentary.html" -Encoding UTF8

# English page
$enTemplate = Get-Content -Raw -Path "templates/daily-commentary-en-template.html" -Encoding UTF8
$enMain = @'
<section>
  <h2 class="en-section-title">Bacterial Intelligence Reveals Civilization’s Fate</h2>
  <div class="news-source">
    <span>Source: UT Austin / Nature Biotechnology</span>
    <span class="source-divider">|</span>
    <span>March 14, 2026 09:00</span>
  </div>
  <div class="content-card">
    <p>Imagine a bacterium that evolved an immune mechanism billions of years ago—Retron—to fend off phages. Today, UT Austin researchers have repurposed that ancient defense into a precision gene-editing scalpel that can fix multiple pathogenic mutations in one operation, boosting editing efficiency from 1.5% to 30%.</p>
    <p>Headlines call it a “revolution,” but the real question is: what is this blade actually cutting?</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Not about curing disease, but rewriting probability</h2>
  <div class="content-card">
    <p>Cystic fibrosis has over a thousand pathogenic mutations; each patient carries a distinct combination. Traditional CRISPR systems target single variants, meaning patients with “rare” mutations are economically written off. As Finkelstein noted, “It’s not commercially viable to develop a therapy for three people.”</p>
    <p>Retron’s disruption is that it replaces entire faulty DNA segments with a healthy template. It doesn’t care which mutation you carry, it just swaps the whole region. In ICS terms, this is an RFD (Recursive Freedom Degree) leap—it expands therapeutic possibility space and opens a new window in gene medicine.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Bacterial immune memory, civilization-scale leap</h2>
  <div class="content-card">
    <p>Pause to consider: the weapon we deploy comes from life’s deepest evolutionary layer. Retron wasn’t invented by humans; it is a defensive code honed over 3.5 billion years.</p>
    <p>ICS’s new life view (NL-1) tells us life is a pattern of information organization, not a random carbon heap. Retron’s repurposing proves this—transferring bacterial information defenses into human cellular repair is the first operational translation of cross-matrix life intelligence.</p>
    <p>But here’s the overlooked detail: delivery is via RNA in lipid nanoparticles, with no exogenous DNA. Under ICS’s REV (Reversibility Principle), this is the highest CRV (Commitment Reversibility Verifiability) class among gene-editing routes—RNA degrades, edits occur at the cellular layer, not the germline. Reversibility remains. That matters for whether a technology can cross ethical red lines into clinic.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">Democratizing gene therapy: light and shadow</h2>
  <div class="content-card">
    <p>“Democratize gene therapy” sounds good, but ICS asks: democratize for whom?</p>
    <p>When a universal gene editing tool is called “off-the-shelf,” it lowers the barrier both for treatment and for misuse. Fixing cystic fibrosis today could become something else tomorrow. The technology itself has no moral brake.</p>
    <p>ICS CSIA rating: somatic therapy is CSIA-4 (global civilization); once it touches germline it jumps to CSIA-5 (intergenerational impact), triggering mandatory C-IRB (Cosmic Institutional Review Board). FRL-4 (extreme externalization ban) and FRL-3 (non-consensual irreversible edit ban) also activate—it’s not alarmism, it’s the normative lighthouse needed when tech accelerates.</p>
  </div>
</section>

<section>
  <h2 class="en-section-title">ICS six metrics conceptual estimate</h2>
  <div class="content-card">
    <table class="metrics-table">
      <thead>
        <tr><th>Metric</th><th>Estimate</th><th>Interpretation (±30% uncertainty)</th></tr>
      </thead>
      <tbody>
        <tr><td>RFD (Recursive Freedom Degree)</td><td>0.75±0.15</td><td>Somatic scope expands significantly; germline remains closed; CRV remains high.</td></tr>
        <tr><td>CRV (Commitment Reversibility Verifiability)</td><td>0.70±0.15</td><td>RNA delivery yields high reversibility, clear regulatory path, rollback capability exists.</td></tr>
        <tr><td>CDI (Civilization Development Index)</td><td>0.65±0.15</td><td>Greatly reduces entropy cost of genetic disease, improves civilization entropy maintenance.</td></tr>
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
    <p>UT Austin’s Retron breakthrough is fundamentally an active repair of life’s internal order. Bacteria use it against viruses; we use it against genetic entropy. The logic is strikingly similar: preserve complexity, preserve possibility, preserve the conditions for survival.</p>
    <p>ICS analysis shows this is a high-leverage entropy-reduction action toward Kardashev Type I, worth pursuing—but only within RFP (Recursive Freedom Principle) guardrails: make today’s gene tools the key that opens the future, not the lock that quietly traps descendants’ choices.</p>
    <p class="disclaimer">【ICS framework analysis | conceptual estimate, not medical advice | Interstellar Civilization Studies】</p>
  </div>
</section>
'@
$enOut = $enTemplate.Replace('{{HEADLINE}}',$content.en.headline).Replace('{{SHORT_SUMMARY}}',$content.en.summary).Replace('{{DATE}}',$content.en.date).Replace('{{READING_TIME}}',$readingTime).Replace('{{FILENAME}}',$filename).Replace('{{FILENAME_EN}}',$filenameEn).Replace('{{MAIN_CONTENT}}',$enMain).Replace('{{RELATED_ARTICLES}}',$related)
$enOut | Set-Content -Path "public/en/daily-commentary.html" -Encoding UTF8

Write-Host "Updated zh and en daily commentary pages."