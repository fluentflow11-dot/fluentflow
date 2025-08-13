// Summary: Extract frames and audio from all MP4s under research/loora/loora AI, then transcribe via OpenAI Whisper API.
import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import ffmpegPath from 'ffmpeg-static';
import fetch from 'node-fetch';
import FormData from 'form-data';

const projectRoot = process.cwd();
const assetsRoot = path.join(projectRoot, 'research', 'loora', 'loora AI');
const stillsRoot = path.join(projectRoot, 'research', 'loora', 'stills');
const transcriptsRoot = path.join(projectRoot, '.taskmaster', 'docs', 'transcripts');
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY) {
  console.error('Missing OPENAI_API_KEY in environment. Aborting.');
  process.exit(1);
}

function listMp4Files(dir) {
  const out = [];
  const stack = [dir];
  while (stack.length) {
    const current = stack.pop();
    if (!fs.existsSync(current)) continue;
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) stack.push(full);
      else if (entry.isFile() && /\.mp4$/i.test(entry.name)) out.push(full);
    }
  }
  return out;
}

function ensureDir(p) {
  fs.mkdirSync(p, { recursive: true });
}

function runFfmpeg(args, cwd) {
  return new Promise((resolve, reject) => {
    const child = spawn(ffmpegPath, args, { cwd, stdio: 'inherit' });
    child.on('exit', (code) => {
      if (code === 0) resolve();
      else reject(new Error(`ffmpeg exited with code ${code}`));
    });
  });
}

async function transcribeWav(wavPath) {
  const form = new FormData();
  form.append('model', 'whisper-1');
  form.append('language', 'en');
  form.append('response_format', 'text');
  form.append('file', fs.createReadStream(wavPath), path.basename(wavPath));
  const headers = form.getHeaders ? form.getHeaders() : {};
  headers.Authorization = `Bearer ${OPENAI_API_KEY}`;
  const res = await fetch('https://api.openai.com/v1/audio/transcriptions', {
    method: 'POST',
    headers,
    body: form,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Whisper API failed: ${res.status} ${text}`);
  }
  return await res.text();
}

async function processOne(mp4Path) {
  const rel = path.relative(assetsRoot, mp4Path);
  const baseName = path.basename(mp4Path, path.extname(mp4Path));
  const parent = path.dirname(rel); // e.g., onboarding1

  const stillsDir = path.join(stillsRoot, parent, baseName);
  const audioDir = path.join(stillsRoot, parent, baseName);
  const wavOut = path.join(audioDir, `${baseName}.wav`);
  const transcriptOut = path.join(transcriptsRoot, parent, `${baseName}.txt`);

  ensureDir(stillsDir);
  ensureDir(audioDir);
  ensureDir(path.dirname(transcriptOut));

  // Extract frames every 1 second as jpgs
  await runFfmpeg(['-y', '-i', mp4Path, '-vf', 'fps=1', path.join(stillsDir, '%04d.jpg')], projectRoot);
  // Extract mono 16kHz wav
  await runFfmpeg(['-y', '-i', mp4Path, '-vn', '-ac', '1', '-ar', '16000', '-f', 'wav', wavOut], projectRoot);

  // Transcribe
  const transcript = await transcribeWav(wavOut);
  await fs.promises.writeFile(transcriptOut, transcript, 'utf8');
  console.log(`Processed: ${rel}`);
}

async function main() {
  if (!fs.existsSync(assetsRoot)) {
    console.error(`Assets folder not found: ${assetsRoot}`);
    process.exit(1);
  }
  ensureDir(stillsRoot);
  ensureDir(transcriptsRoot);
  const files = listMp4Files(assetsRoot);
  if (files.length === 0) {
    console.log('No MP4 files found.');
    return;
  }
  for (const file of files) {
    try {
      await processOne(file);
    } catch (err) {
      console.error(`Failed processing ${file}:`, err.message);
    }
  }
  console.log('All videos processed.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});


