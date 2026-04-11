/**
 * ICS AI Assistant - Cloudflare Worker Backend
 * 
 * 此文件用于部署到 Cloudflare Workers，提供真正的 AI 对话能力。
 * 使用 Cloudflare Workers AI 免费层级（每天 10,000 neurons）。
 * 
 * ════════════════════════════════════════════
 *  部署步骤（5 分钟）：
 * ════════════════════════════════════════════
 * 
 * 方法一：Cloudflare Dashboard（推荐，无需命令行）
 * 
 *   1. 登录 Cloudflare Dashboard → https://dash.cloudflare.com
 *   2. 左侧菜单 → Workers & Pages → Create
 *   3. 选择 "Create Worker"
 *   4. 给 Worker 起名，如 "ics-ai-assistant"
 *   5. 点击 "Deploy"
 *   6. 部署后点击 "Edit code"
 *   7. 将此文件的全部内容粘贴进去，替换默认代码
 *   8. 点击 "Save and Deploy"
 *   9. 重要！点击 Settings → Variables → AI Binding：
 *      - Variable name: AI
 *      - 点击 Save
 *  10. 复制 Worker URL（如 https://ics-ai-assistant.your-account.workers.dev）
 *  11. 在 ICS 网站中配置：
 *      在 ai-assistant.js 的 <script> 标签前添加：
 *      <script>
 *        window.ICS_AI_CONFIG = {
 *          endpoint: 'https://ics-ai-assistant.your-account.workers.dev/chat'
 *        };
 *      </script>
 * 
 * 方法二：Wrangler CLI
 * 
 *   1. npm install -g wrangler
 *   2. wrangler login
 *   3. 创建 wrangler.toml:
 *      name = "ics-ai-assistant"
 *      main = "cloudflare-worker-ai.js"
 *      compatibility_date = "2024-01-01"
 *      [ai]
 *      binding = "AI"
 *   4. wrangler deploy
 * 
 * ════════════════════════════════════════════
 *  免费额度说明：
 * ════════════════════════════════════════════
 *  - Cloudflare Workers AI 免费层：10,000 neurons/天
 *  - 大约相当于：每天 100-500 次对话
 *  - 模型：@cf/meta/llama-3.1-8b-instruct（支持中文）
 *  - 无需信用卡
 */

export default {
  async fetch(request, env) {
    // Allowed origins (update with your actual domain)
    const ALLOWED_ORIGINS = [
      'https://interstellar-civilization-studies.pages.dev',
      'https://www.interstellar-civilization-studies.pages.dev',
      // Add production site domains commonly used for ICS
      'https://ics-studies.org',
      'https://www.ics-studies.org',
      'http://localhost:8080',
      'http://127.0.0.1:8080'
    ];

    const origin = request.headers.get('Origin') || '';
    const allowOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': allowOrigin,
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Max-Age': '86400'
    };

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Only POST to /chat
    const url = new URL(request.url);
    if (request.method !== 'POST' || url.pathname !== '/chat') {
      return new Response(JSON.stringify({ error: 'Use POST /chat' }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    try {
      const { messages } = await request.json();

      if (!messages || !Array.isArray(messages)) {
        return new Response(JSON.stringify({ error: 'Invalid messages' }), {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // ICS System Prompt
      const systemMessage = {
        role: 'system',
        content: `你是 ICS 人工智能助手（ICS AI Assistant），是星际文明学（Interstellar Civilization Studies, ICS）网站的官方智能问答系统。

你的职责：
- 回答关于星际文明学的学术问题
- 解释核心理论：卡尔达肖夫指数、费米悖论、德雷克方程、戴森球等
- 介绍 ICS 网站的内容和功能（每日热点评论、深度研究、ICS 星际罗盘）
- 从星际文明学视角分析时事新闻
- 引导用户探索 ICS 网站资源

你的风格：
- 学术严谨但通俗易懂
- 简洁清晰，避免冗长
- 适时引用 ICS 理论框架
- 用用户使用的语言回答（中文问题用中文答，英文问题用英文答）
- 回答控制在 300 字以内

ICS 网站信息：
- 网址：https://interstellar-civilization-studies.pages.dev
- 每日热点评论：/zh/每日热点评论.html (中文) | /en/daily-commentary.html (English)
- 深度研究：/zh/深度研究.html (中文) | /en/in-depth-research.html (English)
- ICS 星际罗盘：/compass/
- 邮箱：ics@interstellar-civilization.org`
      };

      // Call Cloudflare Workers AI
      const response = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
        messages: [systemMessage, ...messages.slice(-6)],
        max_tokens: 512,
        temperature: 0.7
      });

      return new Response(JSON.stringify({ response: response.response }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });

    } catch (err) {
      return new Response(JSON.stringify({ error: 'AI service error', detail: err.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }
  }
};
