import base64
import os
import sys
import types
import unittest
from pathlib import Path
from unittest.mock import patch


REPO_ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = REPO_ROOT / "src"

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))


if "runpod" not in sys.modules:
    runpod_module = types.ModuleType("runpod")
    serverless_module = types.ModuleType("runpod.serverless")
    utils_module = types.ModuleType("runpod.serverless.utils")
    utils_module.rp_upload = types.SimpleNamespace(
        upload_image=lambda _job_id, _path: "https://example.com/fallback"
    )
    runpod_module.serverless = types.SimpleNamespace(start=lambda _cfg: None)

    sys.modules["runpod"] = runpod_module
    sys.modules["runpod.serverless"] = serverless_module
    sys.modules["runpod.serverless.utils"] = utils_module

if "requests" not in sys.modules:
    requests_module = types.ModuleType("requests")
    requests_module.RequestException = Exception
    requests_module.Timeout = TimeoutError
    requests_module.get = lambda *args, **kwargs: None
    requests_module.post = lambda *args, **kwargs: None
    sys.modules["requests"] = requests_module

if "websocket" not in sys.modules:
    websocket_module = types.ModuleType("websocket")
    websocket_module.enableTrace = lambda _enabled: None
    websocket_module.WebSocketException = Exception
    websocket_module.WebSocketTimeoutException = TimeoutError
    websocket_module.WebSocketConnectionClosedException = ConnectionError

    class _DummyWebSocket:
        connected = False

        def connect(self, *_args, **_kwargs):
            self.connected = True

        def close(self):
            self.connected = False

    websocket_module.WebSocket = _DummyWebSocket
    sys.modules["websocket"] = websocket_module


import handler  # noqa: E402


class TestHandlerMediaOutput(unittest.TestCase):
    def test_infer_mime_type_for_mp4(self):
        self.assertEqual(handler.infer_mime_type("demo.mp4"), "video/mp4")

    def test_infer_media_kind_for_mp4(self):
        self.assertEqual(handler.infer_media_kind("demo.mp4"), "video")

    def test_to_output_entry_returns_base64_for_video_without_s3(self):
        with patch.dict(os.environ, {}, clear=False):
            os.environ.pop("BUCKET_ENDPOINT_URL", None)
            raw_bytes = b"fake-video-bytes"

            result = handler.to_output_entry("job-1", "clip.mp4", raw_bytes)

            self.assertEqual(result["filename"], "clip.mp4")
            self.assertEqual(result["type"], "base64")
            self.assertEqual(result["media_kind"], "video")
            self.assertEqual(result["mime_type"], "video/mp4")
            self.assertEqual(base64.b64decode(result["data"]), raw_bytes)

    def test_to_output_entry_returns_s3_url_when_bucket_endpoint_is_set(self):
        with patch.dict(
            os.environ, {"BUCKET_ENDPOINT_URL": "https://s3.example"}, clear=False
        ):
            with patch.object(
                handler.rp_upload, "upload_image", return_value="https://s3.example/clip.mp4"
            ) as upload_mock:
                result = handler.to_output_entry("job-2", "clip.mp4", b"x")

                self.assertEqual(result["filename"], "clip.mp4")
                self.assertEqual(result["type"], "s3_url")
                self.assertEqual(result["data"], "https://s3.example/clip.mp4")
                self.assertEqual(result["media_kind"], "video")
                self.assertEqual(result["mime_type"], "video/mp4")

                self.assertEqual(upload_mock.call_count, 1)
                call_args = upload_mock.call_args[0]
                self.assertEqual(call_args[0], "job-2")
                self.assertTrue(str(call_args[1]).endswith(".mp4"))


if __name__ == "__main__":
    unittest.main()
