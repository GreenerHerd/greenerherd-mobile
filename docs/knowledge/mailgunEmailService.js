const axios = require('axios');
const FormData = require('form-data');
const { v4: uuidv4 } = require('uuid');
const logger = require('./logger');

class MailgunEmailService {
  constructor(options = {}) {
    const {
      apiKey = process.env.MAILGUN_API_KEY,
      domain = process.env.MAILGUN_DOMAIN,
      baseUrl = process.env.MAILGUN_API_BASE_URL || 'https://api.mailgun.net',
      fromEmail = process.env.MAILGUN_FROM_EMAIL,
      logger: customLogger,
      httpClient,
      timeout = 10000
    } = options;

    if (!apiKey) {
      throw new Error('Mailgun API key is required');
    }

    if (!domain) {
      throw new Error('Mailgun domain is required');
    }

    if (!fromEmail) {
      throw new Error('Sender email (from address) is required');
    }

    this.apiKey = apiKey;
    this.domain = domain;
    this.baseUrl = baseUrl.replace(/\/$/, '');
    this.fromEmail = fromEmail;
    this.logger = customLogger || logger;

    this.httpClient =
      httpClient ||
      axios.create({
        baseURL: this.baseUrl,
        auth: { username: 'api', password: this.apiKey },
        headers: { Accept: 'application/json' },
        timeout
      });
  }

  async sendEmail({
    subject,
    body,
    recipients,
    attachment,
    attachmentFilename = 'attachment.json',
    attachmentContentType,
    from,
    context = {}
  }) {
    const normalizedRecipients = this.#normalizeRecipients(recipients);
    this.#validateInputs({
      subject,
      body,
      recipients: normalizedRecipients,
      attachment,
      attachmentFilename,
      attachmentContentType
    });

    const toAddressList = normalizedRecipients.join(',');
    const fromAddress = from || this.fromEmail;
    const logContext = this.#buildLogContext(context);
    const spanId = logContext.span_id || uuidv4();
    const enrichedLogContext = { ...logContext, span_id: spanId };
    const preparedAttachment = this.#prepareAttachment({
      attachment,
      attachmentFilename,
      attachmentContentType
    });
    const baseMetadata = {
      subject,
      recipients: normalizedRecipients,
      from: fromAddress,
      attachment_filename: preparedAttachment ? preparedAttachment.filename : null,
      attachment_present: Boolean(preparedAttachment),
      attachment_content_type: preparedAttachment ? preparedAttachment.contentType : null
    };

    this.logger.info('mailgun_email_service.send_email.requested', {
      ...enrichedLogContext,
      metadata: this.#mergeMetadata(enrichedLogContext.metadata, baseMetadata)
    });

    const form = new FormData();
    form.append('from', fromAddress);
    form.append('to', toAddressList);
    form.append('subject', subject);
    form.append('text', body);

    if (preparedAttachment) {
      form.append('attachment', preparedAttachment.buffer, {
        filename: preparedAttachment.filename,
        contentType: preparedAttachment.contentType
      });
    }

    const startTime = Date.now();

    try {
      const response = await this.httpClient.post(`/v3/${this.domain}/messages`, form, {
        headers: {
          ...form.getHeaders()
        }
      });

      const durationMs = Date.now() - startTime;
      const result = {
        success: true,
        status: response.status,
        id: response.data && response.data.id ? response.data.id : undefined,
        message: response.data && response.data.message ? response.data.message : undefined
      };

      this.logger.info('mailgun_email_service.send_email.success', {
        ...enrichedLogContext,
        duration_ms: durationMs,
        metadata: this.#mergeMetadata(enrichedLogContext.metadata, {
          ...baseMetadata,
          status: result.status,
          mailgun_id: result.id,
          mailgun_message: result.message
        })
      });

      return result;
    } catch (error) {
      const durationMs = Date.now() - startTime;
      const status = error.response ? error.response.status : undefined;
      const errorData = error.response ? error.response.data : undefined;

      this.logger.error('mailgun_email_service.send_email.failure', {
        ...enrichedLogContext,
        duration_ms: durationMs,
        metadata: this.#mergeMetadata(enrichedLogContext.metadata, {
          ...baseMetadata,
          status,
          error_message: error.message,
          mailgun_error: errorData || null
        })
      });

      const message =
        (errorData && (errorData.message || errorData.error)) ||
        error.message ||
        'Failed to send email via Mailgun';

      throw new Error(`Failed to send email: ${message}`);
    }
  }

  #normalizeRecipients(recipients) {
    if (Array.isArray(recipients)) {
      return recipients;
    }

    if (typeof recipients === 'string') {
      return recipients
        .split(',')
        .map((recipient) => recipient.trim())
        .filter(Boolean);
    }

    return [];
  }

  #validateInputs({ subject, body, recipients, attachment, attachmentFilename, attachmentContentType }) {
    if (!subject || typeof subject !== 'string') {
      throw new Error('Email subject must be a non-empty string');
    }

    if (!body || typeof body !== 'string') {
      throw new Error('Email body must be a non-empty string');
    }

    if (!Array.isArray(recipients) || recipients.length === 0) {
      throw new Error('Recipients must be a non-empty array of email addresses');
    }

    const invalidRecipients = recipients.filter((recipient) => typeof recipient !== 'string' || !recipient.trim());
    if (invalidRecipients.length > 0) {
      throw new Error('Each recipient must be a non-empty string email address');
    }

    if (
      attachmentContentType &&
      typeof attachmentContentType !== 'string'
    ) {
      throw new Error('Attachment content type must be a string when provided');
    }

    if (attachment) {
      if (typeof attachment === 'object' && attachment !== null && Object.prototype.hasOwnProperty.call(attachment, 'content')) {
        const { content, encoding } = attachment;
        if (!content) {
          throw new Error('Attachment content must be provided when using attachment object format');
        }
        if (encoding && typeof encoding !== 'string') {
          throw new Error('Attachment encoding must be a string when provided');
        }
      } else if (!(Buffer.isBuffer(attachment) || typeof attachment === 'string' || typeof attachment === 'object')) {
        throw new Error('Attachment must be a Buffer, string, or object');
      }
    }

    if (attachmentFilename && typeof attachmentFilename !== 'string') {
      throw new Error('Attachment filename must be a string when provided');
    }
  }

  #prepareAttachment({ attachment, attachmentFilename, attachmentContentType }) {
    if (!attachment) {
      return null;
    }

    if (Buffer.isBuffer(attachment)) {
      return {
        buffer: attachment,
        filename: attachmentFilename,
        contentType: attachmentContentType || 'application/octet-stream'
      };
    }

    if (typeof attachment === 'string') {
      return {
        buffer: Buffer.from(attachment, 'base64'),
        filename: attachmentFilename,
        contentType: attachmentContentType || 'application/octet-stream'
      };
    }

    if (typeof attachment === 'object') {
      if (Object.prototype.hasOwnProperty.call(attachment, 'content')) {
        const {
          content,
          filename,
          contentType,
          encoding = 'base64'
        } = attachment;

        let buffer;
        if (Buffer.isBuffer(content)) {
          buffer = content;
        } else if (typeof content === 'string') {
          buffer = Buffer.from(content, encoding);
        } else {
          throw new Error('Attachment content must be a Buffer or string');
        }

        return {
          buffer,
          filename: filename || attachmentFilename,
          contentType: contentType || attachmentContentType || 'application/octet-stream'
        };
      }

      return {
        buffer: Buffer.from(JSON.stringify(attachment, null, 2)),
        filename: attachmentFilename,
        contentType: attachmentContentType || 'application/json'
      };
    }

    throw new Error('Unsupported attachment format');
  }

  #buildLogContext(context = {}) {
    const {
      traceId,
      trace_id,
      correlationId,
      correlation_id,
      userId,
      user_id,
      ip,
      spanId,
      span_id,
      durationMs,
      duration_ms,
      metadata
    } = context;

    return {
      trace_id: traceId || trace_id || null,
      correlation_id: correlationId || correlation_id || null,
      user_id: userId || user_id || null,
      ip: ip || null,
      span_id: spanId || span_id || null,
      duration_ms: durationMs || duration_ms || null,
      metadata: metadata ? { ...metadata } : {}
    };
  }

  #mergeMetadata(baseMetadata = {}, additionalMetadata = {}) {
    return {
      ...baseMetadata,
      ...additionalMetadata
    };
  }
}

module.exports = MailgunEmailService;
